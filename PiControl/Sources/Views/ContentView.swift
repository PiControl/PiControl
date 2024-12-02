//
//  ContentView.swift
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
import MQTTNIO
import PiControlMqttMessages
import Valet

struct ContentView: View {
    
    // MARK: - Public Properties
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedDeviceId: $selectedDeviceId, showPairDeviceView: $showPairDeviceView)
        } detail: {
            Text("Detail View goes here")
        }
        .sheet(isPresented: $showServiceSelection) {
            ServiceSelectionView(selectedUrl: $piControlService)
                .environmentObject(serviceDiscovery)
        }
        .sheet(isPresented: $showLoginView) {
            LoginView(serviceUrl: piControlService!, loggedIn: $loggedIn)
                .environmentObject(loginService)
        }
        .sheet(isPresented: $showPairDeviceView) {
            PairDeviceView()
                .environmentObject(self.mqttClientService)
        }
        .onAppear(perform: self.checkState)
        .onChange(of: piControlService, self.loginToService)
        .onChange(of: loggedIn, self.connectMqtt)
    }
    
    
    // MARK: - Private Properties
    
    @EnvironmentObject
    private var serviceDiscovery: ServiceDiscovery
    @EnvironmentObject
    private var loginService: LoginService
    @EnvironmentObject
    private var mqttClientService: MQTTClientService
    @EnvironmentObject
    private var valet: Valet
    
    @State
    private var selectedDeviceId: Device.ID?
    
    
    @State
    private var showServiceSelection: Bool = false
    @State
    private var showLoginView: Bool = false
    @State
    private var showPairDeviceView: Bool = false
    @State
    private var loggedIn: Bool = false
    
    
    // MARK: - AppStorage
    
    @AppStorage("network.piControlService")
    private var piControlService: URL?
    
}


// MARK: - Private Method Implementation

extension ContentView {
    
    // MARK: - Private Methods
    
    private func checkState() {
        showServiceSelection = (piControlService == nil)
        
        if !showServiceSelection {
            self.loginToService()
        }
    }
    
    private func loginToService() {
        guard let piControlService else { return }
        
        self.showLoginView = !loginService.login(piControlService, $loggedIn, valet: self.valet)
    }
    
    private func connectMqtt() {
        guard self.loggedIn else { return }
        guard self.mqttClientService.client == nil else { return }
        
        guard let credentials = try? valet.credentials() else { return }
        guard let serviceCredentials = credentials[piControlService!] else { return }
        
        do {
            try self.mqttClientService.connect(
                host: self.piControlService!.host()!,
                port: 1883,
                username: serviceCredentials.mqttUsername,
                password: serviceCredentials.mqttPassword
            )
        } catch {
            // TODO Error handling
        }
    }
    
}

#Preview {
    ContentView()
}
