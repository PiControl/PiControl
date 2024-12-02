//
//  PasswordField.swift
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

import SwiftUI

struct PasswordField: View {
    
    // MARK: - Public Properties

    var body: some View {
        HStack {
            if isPasswordVisible {
                TextField("Enter password", text: $password)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                SecureField("Enter password", text: $password)
            }

            Button(action: {
                isPasswordVisible.toggle()
            }) {
                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
    
    @Binding
    var password: String
    
    
    // MARK: - Private Properties
    
    @State
    private var isPasswordVisible: Bool = false
}

