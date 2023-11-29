//
//  Callee.swift
//  CallBook
//
//  Created by M on 29/11/2023.
//

import Foundation
import SwiftData

@Model
final class Calee {
    private(set) var title: String = ""
    private(set) var phoneNumber: String?
    private(set) var email: String?
    private(set) var web: URL?
    private(set) var postcode: String?
    private(set) var origText: String = ""
    
    private(set) var called = false
    private(set) var calls: [Call] = []
    var notes = ""
    
    init(title: String, phoneNumber: String? = nil, email: String? = nil, web: URL? = nil, postcode: String? = nil, origText: String) {
        self.title = title
        self.phoneNumber = phoneNumber
        self.email = email
        self.web = web
        self.postcode = postcode
        self.origText = origText
    }
    
}
