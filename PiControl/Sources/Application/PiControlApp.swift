//
//  PiControlApp.swift
//  PiControl
//
//  Created by Thomas Bonk on 10.11.24.
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

import SwiftUI
import Valet

@main
struct PiControlApp: App {
    
    // MARK: - Public Static Properties
    
    public static var deviceId: String = {
        UIDevice.current.identifierForVendor!.uuidString
    }()
    
    public static let source: String = {
        "controller/\(PiControlApp.deviceId)"
    }()
    
    
    // MARK: - Public Properties
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(serviceBrowser)
                .environmentObject(loginService)
                .environmentObject(mqttClientService)
                .environmentObject(valet)
        }
    }
    
    
    // MARK: - Private Properties
    
    private var serviceBrowser = ServiceDiscovery()
    private var loginService = LoginService()
    private var valet: Valet = {
        let valet = Valet.valet(with: Identifier(nonEmpty: Bundle.main.bundleIdentifier)!, accessibility: .whenUnlocked)
        
        do {
            let credentials: [URL:ServiceCredentials]? = try? valet.credentials()
            
            if credentials == nil {
                try valet.store([URL:ServiceCredentials](), forKey: .credentialsKey)
            }
        } catch {
            fatalError("Error while retrieving or initializing the Valet store: \(error)")
        }
        
        return valet
    }()
    private var mqttClientService = MQTTClientService()
}
