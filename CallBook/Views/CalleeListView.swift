//
//  CalleeListView.swift
//  CallBook
//
//  Created by M on 06/12/2023.
//

import SwiftUI
import SwiftData
import SwiftSoup
import CoreXLSX
import Foundation

struct CalleeListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var callees: [Callee]
    
    @Binding var search: String
    @Binding var searchScope: SearchScope
    @Binding var city: String
    
    init(search: Binding<String>, searchScope: Binding<SearchScope>, city: Binding<String>) {
        _search = search
        _searchScope = searchScope
        _city = city
        
        let searchString = search.wrappedValue
        let scope = searchScope.wrappedValue.rawValue
        let rawCity = city.wrappedValue
        
//        let scopes = SearchScope.allCases.map { $0.rawValue }.sorted()
        
        _callees = Query(filter: #Predicate {
            if searchString.isEmpty {
                return true // $0.city == "" || $0.city == rawCity
            } else {
                if scope == "title" {
                    return $0.title.localizedStandardContains(searchString)// && ($0.city.isEmpty || $0.city == rawCity)
                } else if scope == "notes" {
                    return $0.notes.localizedStandardContains(searchString)// && ($0.city.isEmpty || $0.city == rawCity)
                } else {
                    return $0.title.localizedStandardContains(searchString)// && ($0.city.isEmpty || $0.city == rawCity)
                }
                
            }
//            else if scope == scopes[1] {
//                return $0.notes.localizedStandardContains(search)
//            } else {
//                return false
//            }
            
//            else if scope == scopes[0] {
//               return $0.address.orEmpty.localizedStandardContains(searchString)
//           } else if scope == scopes[2] {
//               return $0.phoneNumber.orEmpty.localizedStandardContains(searchString)
//           }
        }, sort: [/*SortDescriptor(\Callee.distance, order: .forward),*/ SortDescriptor(\Callee.title, comparator: .localizedStandard, order: .forward)])
    }
    
    var body: some View {
        List {
            ForEach(callees) { callee in
                NavigationLink {
                    CalleeView(callee: callee)
                } label: {
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
                }
                .contextMenu {
                    Button(action: {
                        copyToPasteboard(callee.title)
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    if (multipleCopies(of: callee)) {
                        Button(action: {
                            search = callee.title
                            searchScope = .title
                        }) {
                            Label("Show similar", systemImage: "line.3.horizontal.decrease")
                        }
                    }
                    
                }
            }
            .onDelete(perform: deleteItems)
        }
        .toolbar {
//            ToolbarItem {
//                Button(action: {
//                    Task {
//                        let _ = try? await LegalAidSearch.load()
////                        modelContext.insert()
//                    }
//                    
//                }) {
//                    Label("Download", systemImage: "square.and.arrow.down")
//                }
//            }
            
//            ToolbarItem(placement: .destructiveAction) {
//                Button(action: {
////                        showingAlert = true
//                }, label: {
//                    Label("Delete all", systemImage: "trash")
//                })
//            }
            ToolbarItem {
//                Picker("City", selection: $city) {
//                                ForEach(["", ""], id: \.self) {
//                                    Text($0)
//                                        .tag($0)
//                                }
//                            }
//                            .pickerStyle(.menu)
                Menu(content: {
                    Picker("City", selection: $city) {
                        ForEach(Set(callees.map(\.city)).sorted(), id: \.self) { city in
                            Text(city)
                                .tag(city)
                        }
                    }
                }) {
                    Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
    }
    
    private func multipleCopies(of callee: Callee) -> Bool {
//        search.isEmpty && 
        callees.contains(where:  { $0.title == callee.title })
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(callees[index])
            }
        }
    }
    
    private func copyToPasteboard(_ textToCopy: String) {
#if os(iOS)
        UIPasteboard.general.string = textToCopy
#endif
    }
}

//#Preview {
//    CalleeListView()
//}
