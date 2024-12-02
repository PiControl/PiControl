//
//  LoginView.swift
//  PiControl
//
//  Created by Thomas Bonk on 13.11.24.
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

import MarqueeText
import SwiftUI
import Valet

struct LoginView: View {
    
    // MARK: - Public Properties
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Text("Device ID:").bold()
                    MarqueeText(
                        text: PiControlApp.deviceId,
                        font: UIFont.preferredFont(forTextStyle: .body),
                        leftFade: 0,
                        rightFade: 0,
                        startDelay: 0.5
                    )
                    
                    Text("Password:").bold()
                    PasswordField(password: $password)
                }
                .padding()
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Login To Service")
                        .font(.headline)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Login", action: self.login)
                        .disabled(self.password.isEmpty)
                }
            }
        }
    }
    
    let serviceUrl: URL
    var loggedIn: Binding<Bool>
    
    
    // MARK: - Private Properties
    
    @Environment(\.dismiss)
    private var dismiss
    
    @EnvironmentObject
    private var loginService: LoginService
    @EnvironmentObject
    private var valet: Valet
    
    @State
    private var password: String = ""
    @State
    private var serverMessage: String = ""
    
    
    // MARK: - Private Properties
    
    private func login() {
        do {
            let (success, message) = try loginService.login(
                serviceUrl,
                loggedIn,
                username: PiControlApp.deviceId,
                password: password,
                valet: valet
            )
            
            self.serverMessage = message
            
            if success {
                dismiss()
            }
        } catch {
            self.serverMessage = error.localizedDescription
        }
    }
}
