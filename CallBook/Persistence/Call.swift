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
    
    private(set) var calee: Calee
    
    private(set) var on = Date()
    var notes = ""
    
    init(calee: Calee, on: Date = Date(), notes: String = "") {
        self.calee = calee
        self.on = on
        self.notes = notes
    }
}
