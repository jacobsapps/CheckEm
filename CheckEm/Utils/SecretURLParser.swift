//
//  SecretURLParser.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 28/01/2024.
//

import Foundation

final class SecretURLParser {
    
    static let shared = SecretURLParser()
    
    private init() { }
    
    func account2FA(from url: URL) -> Account? {
        guard url.scheme == "otpauth" else { return nil }
        
        guard let name = url.path
            .removingPercentEncoding?
            .replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: ":", with: " — ") else { return nil }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let secret = queryItems.first(where: { $0.name == "secret" })?.value,
              let issuer = queryItems.first(where: { $0.name == "issuer" })?.value else { return nil }
        
        return try? Account(name: String(name), base32String: secret, issuer: issuer)
    }
}
