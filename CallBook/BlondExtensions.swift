//
//  BlondExtensions.swift
//  CallBook
//
//  Created by M on 14/03/2024.
//

import Foundation

extension String? {
    static var orNotFound: String {
        "404"
    }
}

extension String {
    
    public var fromCloud: String {
        NSUbiquitousKeyValueStore.default.string(forKey: self) ?? ""
    }
    
    public func saveToCloud(newValue: String) {
        NSUbiquitousKeyValueStore.default.set(newValue, forKey: self)
    }
}
