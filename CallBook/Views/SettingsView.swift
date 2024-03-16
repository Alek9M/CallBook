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
    @Binding var cities: [String]?
    @Binding var city: String?
    
    @Binding var loaded: Double
    
    var body: some View {
        Form {
            Section("Database") {
                if !LegalAidSearch.lastRefresh.isEmpty  {
                    Text("Last refreshed: \(LegalAidSearch.lastRefresh)")
                }
                Button(action: { refreshAlerts.toggle() }) {
                    if !LegalAidSearch.lastRefresh.isEmpty  {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    } else {
                        Label("Download", systemImage: "arrow.down.to.line")
                    }
                }
                .alert("This action could take several minutes, please don't close the app during the refresh. It will also delete all the data. Continue?", isPresented: $refreshAlerts, actions: {
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
                .padding()
#endif
                .sheet(item: $cities) { cities in
                    CityPickerView(city: $city, cities: cities)
                }
        
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
        LegalAidSearch.deleteRefreshDate()
        let container = modelContext.container
        let importer = BackgroundImporter(modelContainer: container)
        Task.detached(priority: .background) {
            defer {
                DispatchQueue.main.async {
                    loaded = 0
                }
            }
            do {
                try await importer.clear()
                var callees = try await LegalAidSearch.load(with: $loaded, cities: $cities)
                
                let cityTask = Task.detached {
                    while self.city == nil {
                        try await Task.sleep(for: .seconds(1))
                    }
                    return city!
                }
                
                let cit = try await cityTask.value
                
                if !cit.isEmpty {
                    callees = callees.filter { $0.city == cit }
                }
                //                container.deleteAllData()
                //                try await container.mainContext.delete(model: Callee.self)
                //                try await importer.backgroundInsert(callees, with: $loaded)
                //                DispatchQueue.main.asyncAndWait {
                for callee in callees {
                    //                        await container.mainContext.insert(callee)
                    try await importer.insert(callee)
                    loaded += 1
                    print(loaded)
                    if Int(loaded) % 500 == 0 {
                        try await importer.save()
//                                            try modelContext.save()
//                                            try await Task.sleep(for: .milliseconds(1))
                                        }
                }
                let sharedUserDefaults = UserDefaults(suiteName: "group.com.akrp9.CallBook")
                let phoneNumbersData = callees.reduce(into: [String: String]()) { $0[$1.phoneNumber] = $1.title }
                sharedUserDefaults?.set(phoneNumbersData, forKey: "phoneNumbers")
                sharedUserDefaults?.synchronize()
                //                }
            } catch {
                self.error = error
            }
        }
    }
    
    actor BackgroundImporter {
        var modelContainer: ModelContainer
        var modelContext: ModelContext
        
        init(modelContainer: ModelContainer) {
            self.modelContainer = modelContainer
            self.modelContext = ModelContext(modelContainer)
        }
        private var inserting = false
        
        func insert(_ callee: Callee) throws {
            inserting = true
//            let modelContext = ModelContext(modelContainer)
            //                     try await Task.sleep(for: .milliseconds(1))
            print("\n info:" + callee.title)
            modelContext.insert(callee)
//            try modelContext.save()
            inserting = false
        }
        
        func clear() async throws {
            inserting = true
            let modelContext = ModelContext(modelContainer)
            try modelContext.delete(model: Callee.self)
            try modelContext.save()
            inserting = false
        }
        
        func save() async throws {
            inserting = true
//            (modelContext.insertedModelsArray[0] as! Callee).title
//            let modelContext = ModelContext(modelContainer)
            try modelContext.save()
            inserting = false
        }
        
        
        func backgroundInsert(_ callees: [Callee], with progress: Binding<Double>) throws {
            let modelContext = ModelContext(modelContainer)
            
            let batchSize = 500
            let totalObjects = callees.count
            
            for i in 0..<(totalObjects / batchSize) {
                for j in 0..<batchSize {
                    //                     try await Task.sleep(for: .milliseconds(1))
                    modelContext.insert(callees[i])
                    print("\n info:" + j.description)
                }
                print("\n info:" + i.description)
                try modelContext.save()
                progress.wrappedValue += Double(batchSize)
            }
        }
    }
}

extension [String] :Identifiable {
    public var id: Int {
        hashValue
    }
}

//#Preview {
//    SettingsView()
//}
