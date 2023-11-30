//
//  Callee.swift
//  CallBook
//
//  Created by M on 29/11/2023.
//

import Foundation
import SwiftData

@Model
final class Callee {
    private(set) var title: String = ""
    private(set) var phoneNumber: String?
    private(set) var email: [String] = []
    private(set) var web: URL?
    private(set) var postcode: String?
    private(set) var address: String?
    private(set) var origText: String = ""
    private(set) var distance: Float? = nil
    
    private(set) var called = false
    @Relationship(deleteRule: .cascade, inverse: \Call.callee) private(set) var calls: [Call]?
    var notes = ""
    
    var phoneURL: URL? {
        if let phoneNumber = phoneNumber {
            return URL(string: "tel://" + phoneNumber)
        }
        return nil
    }
    
    var emailURL: [URL] {
        email.compactMap { URL(string: "mailto:" + $0) }
    }
    
    var trimmedLines: [String] {
        origText.split(separator: "\n").compactMap { line in
            let trimmed = String(line.trimmingCharacters(in: .whitespacesAndNewlines))
            return trimmed.isEmpty ? nil : trimmed
        }
    }
    
    
    init(title: String, phoneNumber: String? = nil, email: String? = nil, web: URL? = nil, postcode: String? = nil, address: String? = nil, origText: String, distance: Float? = nil) {
        self.title = title
        self.phoneNumber = phoneNumber
        if let email = email {
            self.email = [email]
        }
        self.web = web
        self.postcode = postcode
        self.address = address
        self.origText = origText
        self.calls = []
        self.notes = notes
        self.distance = distance
    }
    
    func add(email: String) {
        self.email.append(email)
    }
    
}
