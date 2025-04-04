//
//  URLRequest.swift
//  RoxchatClientLibrary_Example
//
//  Copyright © 2025 Roxchat. All rights reserved.
//

import Foundation
extension URLRequest {
    var isSendFileRequest: Bool {
        guard let url = url else { return false }
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return (urlComponents?.queryItems?.contains { $0.value == "upload_file" } == true)
    }
}
