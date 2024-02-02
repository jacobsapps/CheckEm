//
//  URL+Extensions.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 02/02/2024.
//

import Foundation

extension URL {

    private var isDeepLink: Bool {
        scheme == "checkem"
    }
    
    var code: String? {
        guard isDeepLink,
              let host,
              host.count == 6 else { return nil }
        return host
    }
}
