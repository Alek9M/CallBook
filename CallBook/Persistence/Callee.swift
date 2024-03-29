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
    
    enum Avaliability: String, CaseIterable, Codable {
    case unavaliable = "􀊂"
        case avaliable = "􀊀"
        case busy = "At capacity"
        case waitingList = "Queue"
    }
    
    private(set) var title = ""
    private(set) var phoneNumber: String?
    var emails: [String] = []
    private(set) var web: URL?
    private(set) var postcode: String?
    private(set) var address: String?
    private(set) var origText = ""
    private(set) var distance: Float? = nil
    var contactUsPage: String? = nil
    var contactForm: String? = nil
//    private(set) var letters: [Letter] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Call.callee) private(set) var calls: [Call]?
    var notes = ""
    var avaliability: Avaliability? = nil
    
    var phoneURL: URL? {
        if let phoneNumber = phoneNumber {
            return URL(string: "tel://" + phoneNumber)
        }
        return nil
    }
    
    var emailURLs: [URL] {
        emails.compactMap { URL(string: "mailto:" + $0) }
    }
    
    var trimmedLines: [String] {
        origText.split(separator: "\n").compactMap { line in
            let trimmed = String(line.trimmingCharacters(in: .whitespacesAndNewlines))
            return trimmed.isEmpty ? nil : trimmed
        }
    }
    
    init(title: String = "", phoneNumber: String? = nil, emails: [String], web: URL? = nil, postcode: String? = nil, address: String? = nil, origText: String = "", distance: Float? = nil, contactUsPage: String? = nil, contactForm: String? = nil, calls: [Call]? = nil, notes: String = "") {
        self.title = title
        self.phoneNumber = phoneNumber
        self.emails = emails
        self.web = web
        self.postcode = postcode
        self.address = address
        self.origText = origText
        self.distance = distance
        self.contactUsPage = contactUsPage
        self.contactForm = contactForm
        self.calls = calls
    }
    
    func add(email: String) {
        self.emails.append(email)
    }
    
}
