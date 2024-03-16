//
//  ConditionalModifiers.swift
//  CallBook
//
//  Created by M on 16/03/2024.
//

import SwiftUI

public extension View {
    
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
