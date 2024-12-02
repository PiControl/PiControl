//
//  Valet+TypedObjectStorage.swift
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
import Valet

extension String {
    public static let credentialsKey = "serviceCredentials"
}

extension Valet {
    
    public func store<T: Encodable>(_ object: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(object)
        
        try self.setObject(data, forKey: key)
    }
    
    public func retrieve<T: Decodable>(forKey key: String) throws -> T {
        let data = try self.object(forKey: key)
        
        let object = try JSONDecoder().decode(T.self, from: data)
        return object
    }
    
}
