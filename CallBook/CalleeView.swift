//
//  CalleeView.swift
//  CallBook
//
//  Created by M on 29/11/2023.
//

import SwiftUI
import SwiftData
import MapKit
import Foundation
import UniformTypeIdentifiers

struct CalleeView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    
    @Bindable var callee: Callee
    @State private var region: MKCoordinateRegion? = nil
    
    @State var searchResults: [MKMapItem] = []
    
    func search() {
        let request = MKLocalSearch.Request ()
        request.naturalLanguageQuery = callee.postcode
        request.resultTypes = .address
        request.region = MKCoordinateRegion(
            center: .init(latitude: 51.5, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0.0125, longitudeDelta: 0.0125))
        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            searchResults = response? .mapItems ?? []
        }
    }
    
    private var lines: String {
        return callee.trimmedLines.reduce("", { $0.appending($1 + "\n") }).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        Form {
            HStack {
                
                Text(lines)
                    .selectionDisabled(false)
                
                if let region = region {
                    Map {
                        ForEach(searchResults, id: \.self) { result in
                            Marker(item: result)
                        }
                    }
                    .frame(width: 300, height: 300)
                }
            }
            
            Section("Details") {
                if let postcode = callee.postcode {
                    detail("PostCode", data: postcode)
                }
                if let distance = callee.distance {
                    detail("Distance", data: "\(distance) miles")
                }
                if let phoneNumber = callee.phoneURL,
                   let phoneNum = callee.phoneNumber {
                    Button(action: { 
                        let call = Call(callee: callee)
                        modelContext.insert(call)
                        openURL(phoneNumber)
                    }) {
                        HStack {
                            Text(phoneNum)
                            Spacer()
                            Label("Call", systemImage: "phone")
                        }
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(action: {
                            copyToPasteboard(phoneNum)
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                    }
                }
                
            }
            
            Section("Notes") {
                TextEditor(text: $callee.notes)
            }
            
            if let calls = callee.calls {
                Section("Calls") {
                    CallsViews(calls: calls)
    //                List {
    //                    ForEach(callee.calls?.sorted(by: { $0.on > $1.on }) ?? []) {  call in
    //                        Text(call.on.formatted(date: .abbreviated, time: .shortened))
    //                    }
    //
    //                    .onDelete(perform: deleteItems)
    //                }
                }
            }
        }
#if os(macOS)
        .padding()
#endif
        .navigationTitle(callee.title)
        .onAppear {
            search()
        }
    }
    
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(callee.calls![index])
//            }
//        }
//    }
    
    private func detail(_ title: String, data: String) -> some View {
        HStack {
            Text(title)
                .bold()
            Spacer()
            Text(data)
        }
        .contextMenu {
            Button(action: {
                copyToPasteboard(data)
            }) {
                Label("Copy", systemImage: "doc.on.doc")
            }
        }
    }
    
    private func copyToPasteboard(_ textToCopy: String) {
#if os(iOS)
        UIPasteboard.general.string = textToCopy
#endif
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Callee.self, configurations: config)
    
    let user = Callee(title: "Rahman & Co Solicitors Ltd", phoneNumber: "0208 809 4643", email: "info@rahmanlaw.com", web: URL(string: "www.rahmanlaw.com") , postcode: "N15 5BY", origText: "5\n                    Rahman & Co Solicitors Ltd\n                  \n                  \n                    \n                      Distance\n                      8.52 miles\n                    \n                  \n                \n                \n                  \n                  \n                    Address:\n                    \n                      33 West Green Road\n                      London\n                      N15 5BY\n                    \n                  \n                  \n                    Helpline:\n                    0208 809 4643\n                  \n                  \n                    \n                      Website:\n                      \n                        www.rahmanlaw.com\n                      \n                    \n                  \n                  \n                    Categories of law covered\n                    \n                      \n                        \n                          Modern slavery\n                        \n                      \n                        \n                          Debt\n                        \n                      \n                        \n                          Housing Loss Prevention Advice Service\n                        \n                      \n                        \n                          Family\n                        \n                      \n                        \n                          Immigration or asylum\n                        \n                      \n                        \n                          Housing", distance: 1.2)
    
    container.mainContext.insert(user)
    container.mainContext.insert(Call(callee: user))
    container.mainContext.insert(Call(callee: user))
    
    return NavigationStack {
        CalleeView(callee: user)
            .modelContainer(container)
    }
}
