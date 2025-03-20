//
//  MQTTClientService.swift
//  PiControl
//
//  Created by Thomas Bonk on 25.11.24.
//  Copyright 2024 Thomas Bonk
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Combine
import Foundation
import Logging
import MQTTNIO
import NIOCore
import PiControlMqttMessages
import SwiftProtobuf
import SwiftUI

fileprivate struct Handler: Identifiable, Cancellable {
    
    // MARK: - Private Properties
    
    fileprivate let id = UUID()
    fileprivate let handler: (any Message) throws -> Void
    fileprivate let messageType: Message.Type
    fileprivate var topic: String
    fileprivate weak var mqttClientService: MQTTClientService?
    
    
    // MARK: - Initialization
    
    public init<M: Message>(service: MQTTClientService, topic: String, _ handler: @escaping (M) throws -> Void) {
        self.topic = topic
        self.mqttClientService = service
        // Use type erasure to store the handler while preserving type safety
        self.handler = { message in
            guard let typedMessage = message as? M else {
                throw NSError(domain: "Handler", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Message type mismatch"])
            }
            try handler(typedMessage)
        }
        self.messageType = M.self
    }
    
    
    // MARK: - Public Methods
    
    public func run(_ message: MQTTMessage) throws {
        guard let payload = message.payload.string else {
            throw NSError(domain: "Handler", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid message payload"])
        }
        
        let typedMessage = try messageType.init(jsonString: payload)
        try handler(typedMessage)
    }
    
    
    // MARK: - Cancellable
    
    public func cancel() {
        self.mqttClientService?.removeHandler(self)
    }
}

class MQTTClientService: ObservableObject {
    
    // MARK: - Public Properties
    
    @Published
    public private(set) var client: MQTTClient?
    
    @Published
    public private(set) var connected = false
    
    
    // MARK: - Private Properties
    
    private var logger = Logger(label: "MQTTClientService")
    private var handlers = [String:[Handler]]()
    
    
    // MARK: - Public Methods
    
    public func connect(host: String, port: Int, username: String, password: String) throws {
        self.client = MQTTClient(
            configuration: MQTTConfiguration(
                target: .host(host, port: port),
                protocolVersion: .version5,
                clientId: PiControlApp.deviceId,
                clean: false,
                credentials: .init(username: username, password: password)
            ))
        
        self.client?.whenMessage(self.onMessageReceived(_:))
        
        Task {
            
            _ = try await self.client!.connect().get()
            
            DispatchQueue.main.async {
                self.connected = self.client!.isConnected
            }
        }
    }
    
    @discardableResult
    public func addHandler<Message: SwiftProtobuf.Message>(
        _ handler: @escaping (Message) -> Void,
        for topic: String) throws -> Cancellable {
            
        var messageHandlers: [Handler] = self.handlers[topic] ?? []
        
        let handler = Handler(service: self, topic: topic, handler)
        messageHandlers.append(handler)
        self.handlers[topic] = messageHandlers
        
        try synchronized {
            try await self.client?.subscribe(to: topic, qos: .exactlyOnce)
        }
            
        return handler
    }
    
    public func publish<Message: SwiftProtobuf.Message>(_ message: Message, to topic: String, qos: MQTTQoS = .exactlyOnce) throws {
        let payload = try message.jsonString()
        let mqttMessage = MQTTMessage(
            topic: topic,
            payload: MQTTPayload(stringLiteral: payload),
            qos: qos
        )
        
        try synchronized {
            try await self.client?.publish(mqttMessage)
        }
    }
    
    
    // MARK: - Private Methods
    
    fileprivate func removeHandler(_ handler: Handler) {
        guard var handlers = self.handlers[handler.topic] else { return }
        handlers.removeAll { $0.id == handler.id }
        self.handlers[handler.topic] = handlers
    }
    
    private func synchronized(_ closure: @escaping () async throws ->  MQTTSingleSubscribeResponse?) throws {
        var err: Error?
        var result: MQTTSingleSubscribeResponse?
        let semaphore = DispatchSemaphore(value: 0)
        Task {
            do {
                result = try await closure()
            } catch {
                err = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        
        if let err {
            throw err
        } else if let result, case .failure(_) = result.result {
            throw result
        }
    }
    
    private func synchronized(_ closure: @escaping () async throws ->  Void) throws {
        var err: Error?
        let semaphore = DispatchSemaphore(value: 0)
        Task {
            do {
                try await closure()
            } catch {
                err = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        
        if let err {
            throw err
        }
    }
    
    private func onMessageReceived(_ message: MQTTMessage) {
        if let handlers = self.handlers[message.topic] {
            do {
                try handlers.forEach { try $0.run(message) }
            } catch {
                self.logger.error("Error while receiving message: \(error)")
            }
        }
    }
}
