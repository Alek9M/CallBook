//
//  ContentView.swift
//  CallBook
//
//  Created by M on 29/11/2023.
//

import SwiftUI
import SwiftData

struct RawData: Codable {
    let origText: String
    let tel: String?
    let web: String?
    let postcode: String?
    let title: String?
    let address: String?
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var callees: [Callee]
    
    @State private var isShowing = false
    @State private var showingAlert = false
    @State private var search = ""
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(callees.filter { search.isEmpty ||
                    $0.title.range(of: search, options: .caseInsensitive) != nil ||
                    $0.address?.range(of: search, options: .caseInsensitive) != nil ||
                    $0.notes.range(of: search, options: .caseInsensitive) != nil ||
                    $0.phoneNumber?.range(of: search, options: .caseInsensitive) != nil
                }.sorted(by: {
                    if let distance1 = $0.distance,
                       let distance2 = $1.distance,
                       distance1 != distance2 {
                        
                        return distance1 < distance2
                        
                    }
                    return $0.title < $1.title
                })) { callee in
                    NavigationLink {
                        CalleeView(callee: callee)
                    } label: {
                        Text(callee.title)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .searchable(text: $search)
            .alert("Everything is gonna be deleted. Are you sure you wanna proceed?", isPresented: $showingAlert) {
                Button("Delete all", role: .destructive) { Task {
                    for callee in callees {
                        modelContext.delete(callee)
                    }
                    try? modelContext.save()
                } }
            }
            .onAppear {
                //                for callee in callees {
                //                    callee.realiseDistance()
                //                }
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Database", systemImage: "plus")
                    }
                    .fileImporter(isPresented: $isShowing, allowedContentTypes: [.json]) { result in
                        
                        switch result {
                        case .success(let Fileurl):
                            Task {
                                do {
                                    // Read the contents of the file
                                    let data = try Data(contentsOf: Fileurl)
                                    
                                    // Decode the JSON data into an array of YourObjectType
                                    let decoder = JSONDecoder()
                                    let objects = try decoder.decode([RawData].self, from: data)
                                    
                                    for object in objects {
                                        if !callees.contains(where: { $0.origText == object.origText }) {
                                            var web: URL? = nil
                                            if let w = object.web {
                                                web = URL(string: w)
                                            }
                                            let callee = Callee(title: object.title ?? "404",
                                                                phoneNumber: object.tel,
                                                                web: web,
                                                                postcode: object.postcode,
                                                                address: object.address,
                                                                origText: object.origText)
                                            modelContext.insert(callee)
                                        }
                                    }
                                    
                                } catch {
                                    // Handle any errors that occur during the process
                                    print("Error: \(error)")
                                }
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                
                ToolbarItem(placement: .destructiveAction) {
                    Button(action: {
                        showingAlert = true
                    }, label: {
                        Label("Delete all", systemImage: "trash")
                    })
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
    
    private func addItem() {
#if os(macOS)
        let openPanel = NSOpenPanel()
        openPanel.prompt = "Select"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = false
        if openPanel.runModal() == NSApplication.ModalResponse.OK {
            let result = openPanel.url // Pathname of the selected folder
            
            if let result = result {
                let path = result.path
                // Your code here
            }
        }
#endif
        isShowing = true
        //        withAnimation {
        //            let newItem = Item(timestamp: Date())
        //            modelContext.insert(newItem)
        //        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(callees[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Callee.self, inMemory: true)
}
