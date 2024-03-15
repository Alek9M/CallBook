//
//  SettingsView.swift
//  CallBook
//
//  Created by M on 13/03/2024.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var error: Error? = nil
    @State private var refreshAlerts = false
    @State private var deletionAlerts = false
    
    @Binding var loaded: Double
    
    var body: some View {
        Form {
            Section("Database") {
                Text("Last refreshed: \(LegalAidSearch.lastRefresh)")
                Button(action: { refreshAlerts.toggle() }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
//                    Label("Download", systemImage: "square.and.arrow.down")
                }
                .alert("This action could take several minutes and will delete all the data. Continue?", isPresented: $refreshAlerts, actions: {
                    Button(action: { load() }, label: { Text("Yes") })
                    Button(action: { refreshAlerts.toggle() }, label: { Text("No") })
                })
                Button(action: { deletionAlerts.toggle() }) {
                    Label("Delete all", systemImage: "trash")
//                    Label("Download", systemImage: "square.and.arrow.down")
                }
                .alert("This action will delete all the data. Continue?", isPresented: $deletionAlerts, actions: {
                    Button(action: { deleteAll() }, label: { Text("Yes") })
                    Button(action: { deletionAlerts.toggle() }, label: { Text("No") })
                })
                
            }
            .disabled(loaded != 0)
//            .onAppear {
//                do {
//                    print(try modelContext.fetchCount(FetchDescriptor<Callee>()))
//                    let callees = try modelContext.fetch(FetchDescriptor<Callee>(), batchSize: 500)
//                    for (index, callee) in callees.enumerated() {
//                        modelContext.delete(callee)
//                        try? modelContext.save()
//                    }
//                } catch {
//                    print(error.localizedDescription)
//                    fatalError("Could not initialize ModelContainer")
//                }
//            }
        }
#if os(macOS)
        .padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
#endif
    }
    
    private func deleteAll() {
        do {
            try modelContext.delete(model: Callee.self)
            LegalAidSearch.deleteRefreshDate()
        } catch {
            self.error = error
        }
    }
    
    private func load() {
        loaded = 1
        let container = modelContext.container
//        let importer = BackgroundImporter(modelContainer: modelContext.container)
        Task.detached(priority: .background) {
            defer {
                DispatchQueue.main.async {
                    loaded = 0
                }
            }
            do {
                let callees = try await LegalAidSearch.load(with: $loaded)
                
//                container.deleteAllData()
                try await container.mainContext.delete(model: Callee.self)
//                try await importer.backgroundInsert(callees)
                for (index, callee) in callees.enumerated() {
                    await container.mainContext.insert(callee)
                    if index % 500 == 0 {
                        try modelContext.save()
                        try await Task.sleep(for: .milliseconds(1))
                        loaded += 100
                    }
                }
                    
            } catch {
                self.error = error
            }
            
        }
    }
    
    actor BackgroundImporter {
        var modelContainer: ModelContainer

        init(modelContainer: ModelContainer) {
            self.modelContainer = modelContainer
        }

        func backgroundInsert(_ callees: [Callee]) async throws {
            let modelContext = ModelContext(modelContainer)

            let batchSize = 500
            let totalObjects = callees.count

            for i in 0..<(totalObjects / batchSize) {
                for j in 0..<batchSize {
                    // try await Task.sleep(for: .milliseconds(1))
                    modelContext.insert(callees[i])
                }

                try modelContext.save()
            }
        }
    }
}

//#Preview {
//    SettingsView()
//}
