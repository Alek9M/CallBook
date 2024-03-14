//
//  SettingsView.swift
//  CallBook
//
//  Created by M on 13/03/2024.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @State var error: Error? = nil
    @State var loading = false
    @State var deleteAlert = false
    
    var body: some View {
        Form {
            Section("Database") {
//                Text("Last refreshed: \(Date(), format: .dateTime)")
                Button(action: { deleteAlert.toggle() }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
//                    Label("Download", systemImage: "square.and.arrow.down")
                }
                .disabled(loading)
                .alert("This action will delete all the data. Continue?", isPresented: $deleteAlert, actions: {
                    Button(action: load, label: { Text("Yes") })
                    Button(action: { deleteAlert.toggle() }, label: { Text("No") })
                })
                Button(action: { try? deleteAll() }) {
                    Label("Delete all", systemImage: "trash")
//                    Label("Download", systemImage: "square.and.arrow.down")
                }
                
            }
        }
#if os(macOS)
        .padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
#endif
    }
    
    private func deleteAll() throws {
        try modelContext.delete(model: Callee.self)
    }
    
    private func load() {
        loading = true
        let container = modelContext.container
        Task.detached(priority: .background) { @MainActor in
            defer {
                DispatchQueue.main.async {
                    loading = false
                }
            }
            do {
                let callees = try await LegalAidSearch.load()
                
//                container.deleteAllData()
                try? container.mainContext.delete(model: Callee.self)
                for callee in callees {
                    container.mainContext.insert(callee)
                }
                    
            } catch {
                self.error = error
            }
            
        }
    }
}

#Preview {
    SettingsView()
}
