//
//  CallsViews.swift
//  CallBook
//
//  Created by M on 30/11/2023.
//

import SwiftUI

struct CallsViews: View {
    @Environment(\.modelContext) private var modelContext
    
    var calls: [Call]
    
    var body: some View {
        ForEach(calls.sorted(by: { $0.on > $1.on })) {  call in
            CallRowView(call: call)
        }
        .onDelete(perform: deleteItems)
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(calls[index])
            }
        }
    }
}

//#Preview {
//    CallsViews()
//}
