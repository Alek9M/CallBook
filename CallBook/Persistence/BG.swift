//
//  BG.swift
//  CallBook
//
//  Created by M on 04/12/2023.
//

import Foundation
import SwiftData

class BackgroundDataHander {
    private(set) var context: ModelContext

    init(with container: ModelContainer) {
        context = ModelContext(container)
    }
}
