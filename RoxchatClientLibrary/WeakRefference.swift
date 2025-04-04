//
//  WeakRefference.swift
//  RoxchatClientLibrary
//
//  Copyright © 2025 Roxchat. All rights reserved.
//

import Foundation

class WeakRefference<T> where T: AnyObject {
    weak var value: T?
    init(_ value: T) {
        self.value = value
    }
}

extension Array where Element:WeakRefference<AnyObject> {
    mutating func releaseElements() {
        self = self.filter { nil != $0.value }
    }
}

