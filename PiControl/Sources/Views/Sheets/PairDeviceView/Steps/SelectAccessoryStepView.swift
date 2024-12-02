//
//  SelectAccessoryStepView.swift
//  PiControl
//
//  Created by Thomas Bonk on 29.11.24.
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
import PiControlMqttMessages
import SwiftUI

struct SelectAccessoryStepView: View, WizardStep {
    
    // MARK: - Public Properties
    
    var body: some View {
        VStack {
            Text("Select an accessory to use.")
                .padding()
            
            Button("Complete") {
                self.wizardController.completeCurrentStep()
            }
        }
        .onAppear(perform: self.subscribeTopics)
    }
    
    let title: String = "Select Accessory"
    let subtitle: String = "Accessories must have registered themselves."
    let isOptional: Bool = false
    
    
    // MARK: - Private Properties
    
    @EnvironmentObject
    private var mqttClientService: MQTTClientService
    
    @EnvironmentObject
    private var wizardController: WizardViewController
    
    @State
    private var accessories: [Accessory] = []
    
    
    // MARK: - Private Methods
    
    private func subscribeTopics() {
        do {
            try self.mqttClientService.addHandler(
                self.receive(accessories:),
                for: "\(PiControlApp.source)/accessories"
            )
        } catch {
            // TODO Error handling
        }
    }
    
    private func receive(accessories message: Accessories) {
        self.accessories.removeAll()
        self.accessories.append(contentsOf: message.accessories)
    }
        
}
