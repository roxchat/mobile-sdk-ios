//
//  DemoVisitor.swift
//  RoxchatClientLibrary_Example
//
//  Copyright © 2025 Roxchat. All rights reserved.
//

import Foundation

struct DemoVisitor: RawRepresentable {
    static let fedor = DemoVisitor(rawValue: 1)
    static let semion = DemoVisitor(rawValue: 2)
    
    var rawValue: Int
}

extension DemoVisitor: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
