//
//  CalleeNote.swift
//  CallBook
//
//  Created by M on 04/12/2023.
//

import SwiftUI

struct CalleeNote: View {
    
    @Binding var callee: Callee
    
    var body: some View {
        Section("Notes") {
            TextEditor(text: $callee.notes)
        }
    }
}

//#Preview {
//    CalleeNote()
//}
