//
//  LoginService.swift
//  PiControl
//
//  Created by Thomas Bonk on 12.11.24.
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

import Foundation
import PiControlRestMessages
import SwiftUI
import UIKit
import Valet

class LoginService: ObservableObject {
    
    // MARK: - Public Methods
    
    public func login(_ url: URL, _ loggedIn: Binding<Bool>, valet: Valet) -> Bool {
        do {
            var credentials = try valet.credentials()
            guard let serviceCredentials = credentials[url] else { return false }
            
            var request = URLRequest(url: url.appendingPathComponent("login"))
            request.httpMethod = "POST"
            request.httpBody = try LoginRequest().encoded()
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(serviceCredentials.token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try awaiting {
                return try await URLSession.shared.data(for: request)
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return false
            }
            guard let loginResponse = try? LoginResponse.decode(from: data) else { return false }
            guard loginResponse.result == .success else { return false }
            
            var mqttCredentials: (String, String)? = nil
            if let mqttCred = loginResponse.mqttCredentials {
                if let pair = decodeCredentials(from: mqttCred) {
                    mqttCredentials = pair
                }
            }
            
            let updatedCredentials = ServiceCredentials(
                password: serviceCredentials.password,
                token: loginResponse.token ?? serviceCredentials.token,
                mqttUsername: mqttCredentials?.0 ?? serviceCredentials.mqttUsername,
                mqttPassword: mqttCredentials?.1 ?? serviceCredentials.mqttPassword)
            
            credentials[url] = updatedCredentials
            try valet.store(credentials, forKey: .credentialsKey)
            
            loggedIn.wrappedValue = true
            return true
        } catch {
            return false
        }
    }
    
    public func login(
        _ url : URL,
        _ loggedIn: Binding<Bool>,
        username: String,
        password: String,
        valet: Valet) throws -> (Bool, String) {
            
        var credentials = try valet.credentials()
        var request = URLRequest(url: url.appendingPathComponent("login"))
        request.httpMethod = "POST"
        request.httpBody = try LoginRequest().encoded()
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(
            "Basic \(encodeCredentials(username: username, password: password))",
            forHTTPHeaderField: "Authorization"
        )
        
        let (data, response) = try awaiting {
            return try await URLSession.shared.data(for: request)
        }
        
        let httpResponse = response as! HTTPURLResponse
        guard (200...299).contains(httpResponse.statusCode) else {
            return (false, httpResponse.statusCode.description)
        }
        guard let loginResponse = try? LoginResponse.decode(from: data) else { return (false, "Invalid response") }
        guard loginResponse.result == .success else { return (false, loginResponse.message) }
        
        var mqttCredentials: (String, String)? = nil
        if let mqttCred = loginResponse.mqttCredentials {
            if let pair = decodeCredentials(from: mqttCred) {
                mqttCredentials = pair
            }
        }
        
        let updatedCredentials = ServiceCredentials(
            password: password,
            token: loginResponse.token ?? "",
            mqttUsername: mqttCredentials?.0 ?? "",
            mqttPassword: mqttCredentials?.1 ?? "")
        
        credentials[url] = updatedCredentials
        try valet.store(credentials, forKey: .credentialsKey)
        
            loggedIn.wrappedValue = true
        return (true, "Login successful")
    }
    
}
