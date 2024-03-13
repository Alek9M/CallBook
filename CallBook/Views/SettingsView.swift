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
                Text("Last refreshed: \(Date(), format: .dateTime)")
                Button(action: { deleteAlert.toggle() }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
//                    Label("Download", systemImage: "square.and.arrow.down")
                }
                .disabled(loading)
                .alert("This action will delete all the data. Continue?", isPresented: $deleteAlert, actions: {
                    Button(action: load, label: { Text("Yes") })
                    Button(action: { deleteAlert.toggle() }, label: { Text("No") })
                })
            }
        }
#if os(macOS)
        .padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
#endif
    }
    
    private func load() {
        loading = true
        Task {
            defer {
                DispatchQueue.main.async {
                    loading = false
                }
            }
            do {
                let callees = try await LegalAidSearch.load()
                DispatchQueue.main.async {
                    callees.forEach(modelContext.insert)
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