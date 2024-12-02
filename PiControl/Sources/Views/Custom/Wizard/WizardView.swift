//
//  WizardView.swift
//  WizardUI
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

import SwiftUI

/// This is the view that manages all the steps that need to be performed in a
/// step by step process.
///
///
@MainActor
public struct WizardView: View {
    
    // MARK: - Public Properties
    
    public var body: some View {
        NavigationStack {
            VStack {
                headerView()
                    .padding(.bottom, 10)
                stepCaption()
                    .padding(.bottom, 10)
                currentStep()
                    .environmentObject(viewController)
                
                Spacer()
                
                navigationButtons()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(self.title)
                        .font(.headline)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: self.dismiss.callAsFunction)
                }
            }
        }
    }
    
    
    // MARK: - Private Properties
    
    @Environment(\.dismiss)
    private var dismiss
    
    private var title: LocalizedStringKey
    
    @ObservedObject
    private var viewController: WizardViewController
    
    
    // MARK: - Initialization
    
    public init(title: LocalizedStringKey, configuration: WizardConfiguration) {
        self.title = title
        self.viewController = .init(configuration: configuration)
        
    }
    
    
    // MARK: - Private Methods
    
    @ViewBuilder
    private func headerView() -> some View {
        let currentStep = viewController.currentStep + 1
        let stepCount = viewController.configuration.steps.count
        
        VStack {
            ProgressView(value: Double(currentStep), total: Double(stepCount))
            
            if viewController.configuration.showStepNumber {
                Text("Step \(currentStep) of \(stepCount)")
                    .font(.footnote)
            }
        }
    }
    
    @ViewBuilder
    private func stepCaption() -> some View {
        VStack {
            Text(viewController.currentStepView.title)
                .font(.headline)
            
            if !viewController.currentStepView.subtitle.isEmpty {
                Text(viewController.currentStepView.subtitle)
                    .font(.subheadline)
            }
        }
    }
    
    @ViewBuilder
    private func currentStep() -> some View {
        AnyView(viewController.currentStepView)
    }
    
    @ViewBuilder
    private func navigationButtons() -> some View {
        HStack {
            Button {
                self.viewController.moveToPreviousStep()
            } label: {
                Image(systemName: "arrowshape.backward.circle")
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            .disabled(self.viewController.currentStep <= 0)
            .accessibilityLabel(Text("Previous Step"))
            .padding(.horizontal, 16)
            
            if self.viewController.currentStep + 1 == self.viewController.configuration.steps.count {
                Button {
                    self.dismiss()
                } label: {
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .frame(width: 32, height: 32)
                }
                .accessibilityLabel(Text("Finish"))
                .padding(.horizontal, 16)
                .disabled(!self.viewController.currentStepCompleted)
            } else {
                Button {
                    self.viewController.moveToNextStep()
                } label: {
                    Image(systemName: "arrowshape.forward.circle")
                        .resizable()
                        .frame(width: 32, height: 32)
                }
                .accessibilityLabel(Text("Next Step"))
                .padding(.horizontal, 16)
                .disabled(!self.viewController.currentStepCompleted)
            }
        }
    }
}
