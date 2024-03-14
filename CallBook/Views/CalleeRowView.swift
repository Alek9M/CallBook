//
//  CalleeRowView.swift
//  CallBook
//
//  Created by M on 14/03/2024.
//

import SwiftUI
import SwiftData

struct CalleeRowView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    private let callee: Callee
    private let descriptor: FetchDescriptor<Callee>
//    @State private var multiple: Bool?
    
    init(callee: Callee) {
        self.callee = callee
        
        let title = callee.title
        descriptor = FetchDescriptor<Callee>(predicate: #Predicate { $0.title == title })
    }
    
    
    var body: some View {
        
        HStack {
            if (callee.calls?.count ?? 0 > 0) {
                Text(callee.calls?.count.description ?? "")
                    .bold()
            }
            Text(callee.title)
            if (multipleCopies(of: callee)) {
                Spacer()
                Label("Has copies", systemImage: "line.3.horizontal.decrease")
                    .labelStyle(.iconOnly)
            }
        }
        .contextMenu {
            Button(action: {
                copyToPasteboard(callee.title)
            }) {
                Label("Copy", systemImage: "doc.on.doc")
            }
            if (multipleCopies(of: callee)) {
                Button(action: {
//                    search = callee.title
//                    searchScope = .title
                }) {
                    Label("Show similar", systemImage: "line.3.horizontal.decrease")
                }
            }
            
        }
    }
    
    private func multipleCopies(of callee: Callee) -> Bool {
        
            return ((try? modelContext.fetchCount(descriptor)) ?? 0) > 1

    }
    
    private func copyToPasteboard(_ textToCopy: String) {
#if os(iOS)
        UIPasteboard.general.string = textToCopy
#endif
    }
}

//#Preview {
//    CalleeRowView(callee: Callee(city: City(title: "London")))
//}
