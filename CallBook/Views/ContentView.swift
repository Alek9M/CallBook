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
    
    static var descriptor: FetchDescriptor<Callee> {
        var descriptor = FetchDescriptor<Callee>(sortBy: [SortDescriptor(\.city, order: .forward)])
        descriptor.propertiesToFetch = [\.city]
        return descriptor
    }
    
    @Environment(\.modelContext) private var modelContext
    @Query(ContentView.descriptor) private var callees: [Callee]
    
    @State private var isShowing = false
    @State private var showingAlert = false
    @State private var search = ""
    @State private var searchScope = SearchScope.title
    @State private var isSettingsShowing = false
    @State private var city = "London" //"Aberdare" //"London"
    @State private var page = 0
    @State private var loading = 0.0
    
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
    
    
    @State private var category: String = "Immigration Asylum"
    
    var body: some View {
        NavigationSplitView {
            CalleeListView(search: $search, searchScope: $searchScope, city: city, category: category, page: $page, loading: loading)
            //            Text(" ")
                .searchable(text: $search)
                .searchScopes($searchScope) {
                    ForEach(SearchScope.allCases, id: \.self) { scope in
                        Text(scope.rawValue.capitalized)
                            .tag(scope)
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
                    ToolbarItem {
                        Menu(content: {
                            Picker("Category", selection: $category) {
                                ForEach(LegalAidSearch.Columns.allCases[7 ..< LegalAidSearch.Columns.allCases.count], id: \.desc) { category in
                                    Text(category.desc)
                                        .tag(category.desc)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            if let set = Optional(Set(callees.map(\.city))) {
                                if set.count > 1 {
                                    Picker("City", selection: $city) {
                                        ForEach(set.sorted(), id: \.self) { city in
                                            Text(city)
                                                .tag(city)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                                else {
                                    EmptyView()
                                        .onAppear() {
                                            city = set.first.orEmpty
                                        }
                                }
                            }
                            
                        }) {
                            Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                        }
                    }
                    
                    
                    ToolbarItem {
                        
                        Button(action: { isSettingsShowing.toggle() }) {
                            if loading == 0 {
                                Label("Settings", systemImage: "gear")
                            } else {
                                ProgressView("Refreshing", value: loading, total: 8000)
                            }
                        }
                        
                        
                    }
                    
                }
                .sheet(isPresented: $isSettingsShowing, content: {
                    SettingsView(loaded: $loading)
                })
        } detail: {
            Text("Select an item")
        }
        //        .onAppear {
        //            try? modelContext.delete(model: Callee.self)
        //        }
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
