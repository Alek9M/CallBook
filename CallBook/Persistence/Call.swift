//
//  Call.swift
//  CallBook
//
//  Created by M on 29/11/2023.
//

import Foundation
import SwiftData

@Model
final class Call: ObservableObject {
    
    enum Status: String, CaseIterable, Codable {
        case voicemail = "Voicemail 􀕼"
        case noAnswer = "No answer"
        case callLater = "Call them back"
        case waitBack = "They will reach back"
        case talked = "Answered"
    }
    
    private(set) var callee: Callee?
    var status: Status? = nil
    var reached: Bool? = nil
    
    private(set) var on = Date()
    var notes = ""
    
    init(callee: Callee, on: Date = Date(), notes: String = "") {
        self.callee = callee
        self.on = on
        self.notes = notes
    }
}
