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
    let distance: Float?
    let emails: [String]?
    let contactUsPageUrl: String?
    let contactFormUrl: String?
}

enum SearchScope: String, CaseIterable {
    case title, notes//, address, phone
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
//    @Query private var callees: [Callee]
    
    @State private var isShowing = false
    @State private var showingAlert = false
    @State private var search = ""
    @State private var searchScope = SearchScope.title
    @State private var selfSearch = false
    
//    private var searched: [Callee] {
//        if search.isEmpty {
//            return callees
//        }
//        return callees.filter {
//            switch searchScope {
//            case .title:
//                return $0.title.range(of: search, options: .caseInsensitive) != nil
//            case .address:
//                return $0.address?.range(of: search, options: .caseInsensitive) != nil
//            case .notes:
//                return $0.notes.range(of: search, options: .caseInsensitive) != nil
//            case .phone:
//                return $0.phoneNumber?.range(of: search, options: .caseInsensitive) != nil
//            }
//        }
//    }
//    
    
    
//    @State private var searchedAndSortedStat: [Callee] = []
    
    var body: some View {
        NavigationSplitView {
            CalleeListView(search: search, searchScope: searchScope)
            .searchable(text: $search)
            .searchScopes($searchScope) {
                ForEach(SearchScope.allCases, id: \.self) { scope in
                    Text(scope.rawValue.capitalized)
                }
            }
//            .alert("Everything is gonna be deleted. Are you sure you wanna proceed?", isPresented: $showingAlert) {
//                Button("Delete all", role: .destructive) { Task {
//                    for callee in callees {
//                        modelContext.delete(callee)
//                    }
//                    try? modelContext.save()
//                } }
//            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
                //#if os(iOS)
                //                ToolbarItem(placement: .navigationBarTrailing) {
                //                    EditButton()
                //                }
                //#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Database", systemImage: "plus")
                    }
                    .fileImporter(isPresented: $isShowing, allowedContentTypes: [.json]) { result in
                        
//                        switch result {
//                        case .success(let Fileurl):
//                            Task {
//                                do {
//                                    guard Fileurl.startAccessingSecurityScopedResource() else { // Notice this line right here
//                                         return
//                                    }
//                                    // Read the contents of the file
//                                    let data = try Data(contentsOf: Fileurl)
//                                    
//                                        Fileurl.stopAccessingSecurityScopedResource()
//                                    
//                                    // Decode the JSON data into an array of YourObjectType
//                                    let decoder = JSONDecoder()
//                                    let objects = try decoder.decode([RawData].self, from: data)
//                                    
//                                    for object in objects {
//                                        if let _ = callees.first(where: { $0.origText == object.origText }) {
////                                            excisting.emails = object.emails ?? []
////                                            excisting.contactUsPage = object.contactUsPageUrl
////                                            excisting.contactForm = object.contactFormUrl
//                                        } else {
//                                            var web: URL? = nil
//                                            if let w = object.web {
//                                                web = URL(string: w)
//                                            }
//                                            let callee = Callee(title: object.title ?? "404",
//                                                                phoneNumber: object.tel, emails: object.emails ?? [],
//                                                                web: web,
//                                                                postcode: object.postcode,
//                                                                address: object.address,
//                                                                origText: object.origText,
//                                                                distance: object.distance,
//                                                                contactUsPage: object.contactUsPageUrl,
//                                                                contactForm: object.contactFormUrl)
//                                            modelContext.insert(callee)
//                                        }
//                                    }
//                                    
//                                } catch {
//                                    // Handle any errors that occur during the process
//                                    print("Error: \(error)")
//                                }
//                            }
//                        case .failure(let error):
//                            print(error)
//                        }
                    }
                }
                
                
            }
            .sheet(isPresented: $selfSearch, content: {
                SearchView()
            })
        } detail: {
            Text("Select an item")
        }
    }
    
    private func addItem() {
//#if os(macOS)
//        let openPanel = NSOpenPanel()
//        openPanel.prompt = "Select"
//        openPanel.allowsMultipleSelection = false
//        openPanel.canChooseDirectories = true
//        openPanel.canCreateDirectories = false
//        openPanel.canChooseFiles = false
//        if openPanel.runModal() == NSApplication.ModalResponse.OK {
//            let result = openPanel.url // Pathname of the selected folder
//            
//            if let result = result {
//                let path = result.path
//                // Your code here
//            }
//        }
//#endif
        isShowing = true
        //        withAnimation {
        //            let newItem = Item(timestamp: Date())
        //            modelContext.insert(newItem)
        //        }
    }
    
    
}

#Preview {
    ContentView()
        .modelContainer(for: Callee.self, inMemory: true)
}
