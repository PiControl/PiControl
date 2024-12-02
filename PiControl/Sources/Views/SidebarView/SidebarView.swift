//
//  SidebarView.swift
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

import PiControlMqttMessages
import SwiftUI

struct SidebarView: View {
    
    // MARK: - Public Properties
    
    var body: some View {
        ConditionalView(ìf: self.mqttClientService.connected) {
            ConditionalView(ìf: self.devices.isEmpty) {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .padding()
                    Text("No devices found.")
                }
            } else: {
                DevicesListView(devices: self.devices, selectedDeviceId: $selectedDeviceId)
            }
            .onAppear(perform: self.subscribeTopics)
            .onAppear(perform: self.requestDevices)
        } else: {
            VStack {
                Image(systemName: "cable.connector.slash")
                    .resizable()
                    .frame(width: 64, height: 64)
                    .padding()
                
                Text("Not connected to the PiControl server.")
            }
        }
        .toolbar {
            Button(action: self.requestDevices) {
                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle")
            }
            Button(action: { self.showPairDeviceView.toggle() }) {
                Image(systemName: "plus.circle")
            }

        }
    }
    
    @Binding
    var selectedDeviceId: Device.ID?
    @Binding
    var showPairDeviceView: Bool
    
    
    // MARK: - Private Properties
    
    @EnvironmentObject
    private var mqttClientService: MQTTClientService
    
    @State
    private var devices: [Device] = []    
    
    // MARK: - Private Methods
    
    private func subscribeTopics() {
        do {
            try self.mqttClientService.addHandler(
                self.receive(devices:),
                for: "\(PiControlApp.source)/devices"
            )
        } catch {
            // TODO Error handling
        }
    }
    
    private func receive(devices message: Devices) {
        self.devices.removeAll()
        self.devices.append(contentsOf: message.devices)
    }
    
    private func requestDevices() {
        var headers = MessageHeaders()
        headers.source = PiControlApp.source
        var message = ReadDevices()
        message.headers = headers
        
        do {
            try self.mqttClientService.publish(message, to: "coordinator/devices")
        } catch {
            // TODO Error handling
        }
    }
}
