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
    @Binding var page: Int
    var category: String
    
    init(search: Binding<String>, searchScope: Binding<SearchScope>, city: String, category: String, page: Binding<Int>) {
        _search = search
        _searchScope = searchScope
        _page = page
//        _city = city
        self.category = category
        
        let searchString = search.wrappedValue
        let scope = searchScope.wrappedValue.rawValue
//        let rawCity = city.wrappedValue
        
//        let scopes = SearchScope.allCases.map { $0.rawValue }.sorted()
        let pageNumber = page.wrappedValue
        
        let cityID = city
        let categoryID = category
        
        var predicate: Predicate<Callee> = #Predicate {
            if searchString.isEmpty {
                return $0.city == cityID /*&& $0.categories != nil && $0.categories!.contains(where: { $0.customID == categoryID})*/
            } else {
//                if scope == "title" {
//                    return $0.city?.customID == cityID /*&& $0.categories.flatMap({ $0.customID == categoryID ? self : nil }) == true*/ && $0.title.localizedStandardContains(searchString)
//                } else if scope == "notes" {
//                    return $0.city?.customID == cityID /*&& $0.categories.flatMap({ $0.customID == categoryID ? self : nil }) == true*/ && $0.notes.localizedStandardContains(searchString)
//                } else {
//                    return $0.city?.customID == cityID /*&& $0.categories.flatMap({ $0.customID == categoryID ? self : nil })*/ && $0.title.localizedStandardContains(searchString)
//                }
                return false
            }
        }
        
        
        var descriptor = FetchDescriptor<Callee>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.title, order: .forward)])
        descriptor.propertiesToFetch = [\.title, \.origText]
        descriptor.relationshipKeyPathsForPrefetching = [\.calls]
        let pageSize = 30
        descriptor.fetchLimit = pageSize + pageNumber * pageSize
//        descriptor.fetchOffset = pageNumber * pageSize
        _callees = Query(descriptor)
    }
    
    var body: some View {
        List {
            ForEach(Array(callees.enumerated()), id: \.offset) { index, callee in
                NavigationLink {
                    CalleeView(callee: callee)
                } label: {
                    CalleeRowView(callee: callee)
                    .onAppear {
                        if index == callees.count - 5 &&
                            (try? modelContext.fetchCount(FetchDescriptor<Callee>())) ?? 30 > callees.count {
                            withAnimation {
                                page += 1
                            }
                        }
                    }
                }
                .contextMenu {
                    Button(action: {
                        copyToPasteboard(callee.title)
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
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
