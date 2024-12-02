//
//  ServiceDiscovery.swift
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

import Ciao
import Foundation

class ServiceDiscovery: ObservableObject {
    
    // MARK: - Service Struct
    
    struct Service: Hashable, Identifiable {
        
        // MARK: - Properties
        
        let name: String
        let hostname: String
        let port: Int
        
        var id: String {
            hostname
        }
    }
    
    // MARK: - Public Properties
    
    @Published
    public private(set) var netServices: Set<NetService> = []
    
    public var pictrlServices: [Service] {
        netServices.filter({ $0.type == "_pictrl._tcp." }).map { Service(name: $0.name, hostname: $0.hostName!, port: $0.port) }
    }
    
    public var mqttServices: [Service] {
        netServices.filter({ $0.type == "_mqtt._tcp." }).map { Service(name: $0.name, hostname: $0.hostName!, port: $0.port) }
    }
    
    
    // MARK: - Private Properties
    
    let browser: CiaoBrowser
    
    
    // MARK: - Initialization
    
    init() {
        self.browser = CiaoBrowser()
        
        // get notified when a service is found
        browser.serviceFoundHandler = self.serviceFound(_:)
        // register to automatically resolve a service
        browser.serviceResolvedHandler = self.serviceResolved(_:)
        browser.serviceRemovedHandler = self.serviceRemoved(_:)
        
        self.browser.browse(type: .tcp("pictrl"), domain: "local.")
    }
    
    
    // MARK: - Private Methods
    
    private func serviceFound(_ service: NetService) {
        // Empty by design
    }
    
    private func serviceResolved(_ result: Result<NetService, ErrorDictionary>) {
        guard case .success(let service) = result else { return }
        
        self.netServices.insert(service)
    }
    
    private func serviceRemoved(_ service: NetService) {
        self.netServices.remove(service)
    }
}
