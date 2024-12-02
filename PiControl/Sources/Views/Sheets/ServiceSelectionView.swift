//
//  ServiceSelectionView.swift
//  PiControl
//
//  Created by Thomas Bonk on 11.11.24.
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

struct ServiceSelectionView: View {
    
    // MARK: - Public Properties
    
    var body: some View {
        NavigationStack {
            List(self.serviceDiscovery.pictrlServices, id: \.id, selection: $selectedServiceId) { service in
                VStack(alignment: .leading) {
                    Text("\(service.name)")
                        .bold()
                    Text("\(service.hostname)")
                        .font(.footnote)
                }
                .tag(service.id)
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("PiControl Devices")
                        .font(.headline)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Connect", action: self.connectToService)
                        .disabled(self.selectedServiceId == nil)
                }
            }
        }
    }
    
    @Binding
    var selectedUrl: URL?
    
    
    // MARK: - Private Properties
    
    @Environment(\.dismiss)
    private var dismiss
    
    @EnvironmentObject
    private var serviceDiscovery: ServiceDiscovery
    
    @State
    private var selectedServiceId: String?
    
    
    // MARK: - Private Methods
    
    private func connectToService() {
        DispatchQueue.main.async {
            if self.changeSelectedService() {
                DispatchQueue.main.async {
                    dismiss()
                }
            }
        }
    }
    
    private func changeSelectedService() -> Bool {
        guard let id = selectedServiceId else { return false }
        guard let service = serviceDiscovery.pictrlServices.first(where: { $0.id == id }) else { return false }
        
        self.selectedUrl = URL(string: "http://\(service.hostname):\(service.port)")
        return true
    }
}
