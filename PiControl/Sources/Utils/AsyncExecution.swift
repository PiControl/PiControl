//
//  AsyncExecution.swift
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

import Foundation

public func awaiting(_ closure: @escaping () async -> Void)  {
    let semaphore = DispatchSemaphore(value: 0)
    
    Task {
        await closure()
        semaphore.signal()
    }
    
    // Wait for the task to complete
    semaphore.wait()
}

public func awaiting(_ closure: @escaping () async throws -> Void) throws {
    let semaphore = DispatchSemaphore(value: 0)
    var err: Error? = nil
    
    Task {
        do {
            try await closure()
        } catch {
            err = error
        }
        semaphore.signal()
    }
    
    // Wait for the task to complete
    semaphore.wait()
    
    if let err {
        throw err
    }
}

public func awaiting<R>(_ closure: @escaping () async -> R) -> R  {
    let semaphore = DispatchSemaphore(value: 0)
    var result: R!
    
    Task {
        result = await closure()
        semaphore.signal()
    }
    
    // Wait for the task to complete
    semaphore.wait()
    
    return result
}

public func awaiting<R>(_ closure: @escaping () async throws -> R) throws -> R {
    let semaphore = DispatchSemaphore(value: 0)
    var result: R!
    var err: Error? = nil
    
    Task {
        do {
            result = try await closure()
        } catch {
            err = error
        }
        semaphore.signal()
    }
    
    // Wait for the task to complete
    semaphore.wait()
    
    if let err {
        throw err
    }
    
    return result
}
