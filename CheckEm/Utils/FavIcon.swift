//
//  FavIcon.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 28/01/2024.
//

import Foundation

struct FavIcon {
    
    let url: URL
    
    init(issuer: String) {
        let domain = "\(issuer).com"
        let url = URL(string: "https://www.google.com/s2/favicons?sz=256&domain=\(domain)")!
        self.url = url
    }
}
