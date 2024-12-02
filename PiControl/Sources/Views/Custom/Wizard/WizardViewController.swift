//
//  WizardViewController.swift
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

import Foundation

public class WizardViewController: ObservableObject {
    
    // MARK: - Public Properties
    
    @Published
    public private(set) var currentStep: Int = 0
    @Published
    public private(set) var currentStepCompleted: Bool = false
    
    public private(set) var configuration: WizardConfiguration
    
    public var currentStepView: any WizardStep {
        return configuration.steps[currentStep]
    }
    
    
    // MARK: - Initialization
    
    public init(configuration: WizardConfiguration) {
        self.configuration = configuration
    }
    
    
    // MARK: - Public Methods
    
    public func completeCurrentStep() {
        self.currentStepCompleted = true
    }
    
    
    // MARK: - Internal Methods
    
    func moveToPreviousStep() {
        if self.currentStep > 0 {
            self.currentStep -= 1
            self.currentStepCompleted =
                false || (self.currentStepView.isOptional
                          && self.configuration.canSkipOptionalSteps)
        }
    }
    
    func moveToNextStep() {
        if self.currentStep < configuration.steps.count - 1 {
            self.currentStep += 1
            self.currentStepCompleted =
                false || (self.currentStepView.isOptional
                          && self.configuration.canSkipOptionalSteps)
        }
    }
}
