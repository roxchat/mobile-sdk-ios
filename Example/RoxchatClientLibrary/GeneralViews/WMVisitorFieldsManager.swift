//
//  WMVisitorFieldsManager.swift
//  RoxchatClientLibrary_Example
//
//  Created by Anna Frolova on 22.11.2023.
//  Copyright © 2023 Roxchat. All rights reserved.
//

import Foundation
import RoxchatClientLibrary

class WMVisitorFieldsManager {
    
    var visitorFieldsParser: WMVisitorFieldsParser
    
    var isSelectedVisitorValid: Bool {
        let demoVisitor = DemoVisitor(rawValue: selectedVisitor ?? 0)
        let isSpecialDemoVisitor = demoVisitor == .fedor || demoVisitor == .semion
        return (isSpecialDemoVisitor && getVisitorData() != nil) || !isSpecialDemoVisitor
    }
    
    @UserDefault(key: UserDefaultsKeys.selectedVisitor)
    private var selectedVisitor: Int?
    
    @UserDefault(key: UserDefaultsKeys.currentVisitor)
    private var currentVisitor: Int?

    @UserDefault(key: UserDefaultsKeys.fedor)
    private var fedorData: Data?

    @UserDefault(key: UserDefaultsKeys.semion)
    private var semionData: Data?
    
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        visitorFieldsParser = WMVisitorFieldsParser(
            networkManager: networkManager,
            completionHandler: nil
        )
        initialSetup()
    }
    
    func set(selectedVisitor: DemoVisitor?) {
        self.selectedVisitor = selectedVisitor?.rawValue
        updateVisitorIfNeeded(visitor: selectedVisitor)
    }
    
    func getVisitorData(for demoVisitor: DemoVisitor = .selectedVisitor) -> Data? {
        switch demoVisitor {
        case .semion:
            return semionData
        case .fedor:
            return fedorData
        default:
            return nil
        }
    }
    
    func updateCurrentVisitor() {
        currentVisitor = selectedVisitor
    }
    
    func updateVisitorsData() {
        update(demoVisitor: .fedor)
        update(demoVisitor: .semion)
    }
    
    private func initialSetup() {
        visitorFieldsParser.set(completion: self)
        updateVisitorIfNeeded(visitor: .fedor)
        updateVisitorIfNeeded(visitor: .semion)
    }
    
    private func updateVisitorIfNeeded(visitor: DemoVisitor?) {
        guard let visitor = visitor else { return }
        var currentData: Data?
        switch visitor {
        case .fedor:
            currentData = fedorData
        case .semion:
            currentData = semionData
        default:
            currentData = nil
        }
        
        guard let data = currentData else {
            update(demoVisitor: visitor)
            return
        }

        if isVisitorExpired(visitorData: data) {
            update(demoVisitor: visitor)
        }
    }
    
    private func update(demoVisitor: DemoVisitor) {
        if #available(iOS 13.0, *) {
            Task.init {
                let output = try await visitorFieldsParser.parse(value: demoVisitor)
                save(visitor: output.1, data: output.0)
            }
        } else {
            visitorFieldsParser.parse(value: demoVisitor)
        }
    }
    
    private func isVisitorExpired(visitorData: Data) -> Bool {
        guard let dictionary = try? JSONSerialization.jsonObject(with: visitorData) as? [String: Any]? else {
            return true
        }
        guard let dateInSecond = dictionary?[HelperVisitorKeys.expires] as? Int else { return true }
        return TimeInterval(dateInSecond) < Date().timeIntervalSince1970
    }
    
    private func save(visitor: DemoVisitor, data: Data?) {
        switch visitor {
        case .fedor:
            fedorData = data
        case .semion:
            semionData = data
        default:
            break
        }
    }
    
    private enum HelperVisitorKeys {
        static let expires = "expires"
    }
}

extension WMVisitorFieldsManager: WMVisitorFieldsParserCompletionHandler {
    typealias OutputType = DemoVisitorOutput
    typealias ErrorType = WMVisitorFieldsError

    func onSuccess(value: DemoVisitorOutput) {
        save(visitor: value.1, data: value.0)
    }

    func onFailure(error: WMVisitorFieldsError) { }
}

extension DemoVisitor {
    static var selectedVisitor: DemoVisitor {
        let rawValue = UserDefaults
            .standard
            .value(forKey: UserDefaultsKeys.selectedVisitor)
            .flatMap { $0 as? Int } ?? 0
        return DemoVisitor(rawValue: rawValue)
    }
    
    static var currentVisitor: DemoVisitor {
        let rawValue = UserDefaults
            .standard
            .value(forKey: UserDefaultsKeys.currentVisitor)
            .flatMap { $0 as? Int } ?? 0
        return DemoVisitor(rawValue: rawValue)
    }
}

fileprivate enum UserDefaultsKeys {
    static let fedor = "DemoVisitor_Fedor"
    static let semion = "DemoVisitor_Semion"
    static let selectedVisitor = "DemoVisitor_selectedVisitor"
    static let currentVisitor = "DemoVisitor_currentVisitor"
}
