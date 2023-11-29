//
//  Call.swift
//  CallBook
//
//  Created by M on 29/11/2023.
//

import Foundation
import SwiftData

@Model
final class Call {
    
    private(set) var callee: Callee
    
    private(set) var on = Date()
    var notes = ""
    
    init(callee: Callee, on: Date = Date(), notes: String = "") {
        self.callee = callee
        self.on = on
        self.notes = notes
    }
}
