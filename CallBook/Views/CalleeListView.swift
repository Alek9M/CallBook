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
    
    @State private var searchedAndSortedStat: [Callee] = []
    
//    @Binding var search: String
//    @Binding var searchScope: SearchScope
    
    private var searchedAndSorted: [Callee] {
        return callees
        callees.sorted(by: {
            if let distance1 = $0.distance,
               let distance2 = $1.distance,
               distance1 != distance2 {
                
                return distance1 < distance2
                
            }
            return $0.title < $1.title
        })
    }
    
    init(search: String, searchScope: SearchScope) {
//        _search = search
//        _searchScope = searchScope
        
//        let searchString = search.wrappedValue
        let scope = searchScope.rawValue
        
        let scopes = SearchScope.allCases.map { $0.rawValue }.sorted()
        
        _callees = Query(filter: #Predicate {
            if search.isEmpty {
                return true
            } else {
                return $0.title.localizedStandardContains(search)
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
        }, sort: [SortDescriptor(\Callee.distance, order: .forward), SortDescriptor(\Callee.title, comparator: .localizedStandard, order: .forward)])
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
//                            search = callee.title
//                            searchScope = .title
                        }) {
                            Label("Show similar", systemImage: "line.3.horizontal.decrease")
                        }
                    }
                    
                }
            }
            .onDelete(perform: deleteItems)
            
            //            .onAppear {
            //                searchedAndSortedStat = searchedAndSorted
            //            }
            //            .onChange(of: search) {
            //                searchedAndSortedStat = searchedAndSorted
            //            }
        }
        .toolbar {
            ToolbarItem {
                Button(action: {
                    Task {
                        let _ = try? await LegalAidSearch.load()
//                        modelContext.insert()
                    }
                    
                }) {
                    Label("Download", systemImage: "square.and.arrow.down")
                }
            }
            
            ToolbarItem(placement: .destructiveAction) {
                Button(action: {
//                        showingAlert = true
                }, label: {
                    Label("Delete all", systemImage: "trash")
                })
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
