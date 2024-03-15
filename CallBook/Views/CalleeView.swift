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
    
    var callee: Callee
    
    static private let london = MKCoordinateRegion(
        center: .init(latitude: 51.5, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    
    @State private var region: MKCoordinateRegion = CalleeView.london
    
    @State private var searchResults: [MKMapItem] = []
    @State private var notes = ""
    @State private var task: Task<(), Never>? = nil
    
    private func search() {
        searchResults = []
        let request = MKLocalSearch.Request ()
        request.naturalLanguageQuery = callee.postcode
        request.resultTypes = .address
        
        request.region.span = MKCoordinateSpan(latitudeDelta: 0.0125, longitudeDelta: 0.0125)
        //        request.region = MKCoordinateRegion(
        //            center: .init(latitude: 51.5, longitude: 0),
        //            span: MKCoordinateSpan(latitudeDelta: 0.0125, longitudeDelta: 0.0125))
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
            
            //            Picker("Avaliability", selection: $callee.avaliability) {
            //                Text("")
            //                    .tag(nil as Callee.Avaliability?)
            //                ForEach(Callee.Avaliability.allCases, id: \.rawValue) { avaliability in
            //                    Text(avaliability.rawValue)
            ////                        .tag(avaliability)
            //                }
            //            }
            Section("Categories") {
                ForEach(callee.origText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines).filter { !$0.isEmpty }, id: \.self) { categoryString in
                    Text(categoryString)
#if os(macOS)
                        .padding(.leading)
#endif
                }
            }
            
            Section("Address") {
                if let address = callee.address {
                    ForEach(address.components(separatedBy: .newlines).filter { !$0.isEmpty }, id: \.self) { addressLine in
                        Text(addressLine)
#if os(macOS)
                            .padding(.leading)
#endif
                    }
                }
                if !callee.city.isEmpty && callee.city != "404" {
                    detail("City", data: callee.city)
                }
                if !callee.postcode.isEmpty {
                    detail("PostCode", data: callee.postcode)
                        .onAppear {
                            search()
                        }
                }
                //                if (region.center.latitude, region.center.longitude) != (CalleeView.london.center.latitude, CalleeView.london.center.longitude) {
                Map//(coordinateRegion: $region, showsUserLocation: true)
                {
                    ForEach(searchResults, id: \.self) { result in
                        Marker(item: result)
                    }
                }
                .frame(height: 300)
                .onTapGesture {
                    if let item = searchResults.first,
                       let url = URL(string: "maps://?saddr=&daddr=\(item.placemark.coordinate.latitude),\(item.placemark.coordinate.longitude)") {
//                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        openURL(url)
                    }
//                    if UIApplication.shared.canOpenURL(url!) {
//                          UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//                    }
                }
                //                }
            }
            
            
            //                Text(lines)
            //                    .selectionDisabled(false)
            
            
            
            Section("Details") {
                if let distance = callee.distance {
                    detail("Distance", data: "\(distance) miles")
                }
                if let phoneNumber = callee.phoneURL {
                    Button(action: {
                        let call = Call(callee: callee)
                        modelContext.insert(call)
                        openURL(phoneNumber)
                    }) {
                        HStack {
                            Text(callee.phoneNumber)
                            Spacer()
                            Label("Call", systemImage: "phone")
                        }
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(action: {
                            copyToPasteboard(callee.phoneNumber)
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                    }
                }
                if let web = callee.web {
                    Link(destination: web) {
                        Label("Website", systemImage: "network")
                    }
                }
                //                if let contactUs =
                
            }
            
            //            Section("Emails") {
            //                ForEach(callee.emails, id: \.self) { email in
            //                    HStack {
            //                        Text(email)
            //                        if let url = URL(string: "mailto:" + email) {
            //                            Spacer()
            //                            Button(action: {
            //                                openURL(url)
            //                            }) {
            //                                Label("Send", systemImage: "envelope")
            //                            }
            //                            .buttonStyle(.plain)
            //                        }
            //                    }
            //                }
            //                .onDelete(perform: deleteItems)
            //
            //                Button(action: {}) {
            //                    Label("Add email", systemImage: "plus")
            //                }
            //            }
            
            //            CalleeNote(callee: .constant(callee))
            Section("Notes") {
                TextEditor(text: $notes)
#if os(macOS)
                .frame(height: 100)
#endif
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
        .onChange(of: callee) {
            search()
        }
#endif
        .navigationTitle(callee.title)
        .onChange(of: callee) {
            stopNoteTaking()
            startNoteTaking()
            notes = callee.notes
        }
        .onAppear {
            //            search()
            startNoteTaking()
        }
        .onDisappear {
            stopNoteTaking()
            callee.notes = notes
        }
    }
    
    private func stopNoteTaking() {
        if let task = task {
            task.cancel()
            //            callee.notes = notes
        }
    }
    
    private func startNoteTaking() {
        notes = callee.notes
        task = Task.detached(priority: .background) {
            while let task =  task,
                  !task.isCancelled,
                  let _ = try? await Task.sleep(nanoseconds: 3_000_000_000),
                  callee.notes != notes {
                DispatchQueue.main.async {
                    callee.notes = notes
                }
            }
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
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                callee.emails = callee.emails.filter { $0 != callee.emails[index] }
            }
        }
    }
    
    private func copyToPasteboard(_ textToCopy: String) {
#if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(textToCopy, forType: .string)
#else
        UIPasteboard.general.string = textToCopy
#endif
        
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Callee.self, configurations: config)
    
    let user = Callee(title: "Rahman & Co Solicitors Ltd", phoneNumber: "0208 809 4643", emails: ["info@rahmanlaw.com"], web: URL(string: "www.rahmanlaw.com") , postcode: "N15 5BY", origText: "5\n                    Rahman & Co Solicitors Ltd\n                  \n                  \n                    \n                      Distance\n                      8.52 miles\n                    \n                  \n                \n                \n                  \n                  \n                    Address:\n                    \n                      33 West Green Road\n                      London\n                      N15 5BY\n                    \n                  \n                  \n                    Helpline:\n                    0208 809 4643\n                  \n                  \n                    \n                      Website:\n                      \n                        www.rahmanlaw.com\n                      \n                    \n                  \n                  \n                    Categories of law covered\n                    \n                      \n                        \n                          Modern slavery\n                        \n                      \n                        \n                          Debt\n                        \n                      \n                        \n                          Housing Loss Prevention Advice Service\n                        \n                      \n                        \n                          Family\n                        \n                      \n                        \n                          Immigration or asylum\n                        \n                      \n                        \n                          Housing", distance: 1.2)
    
    container.mainContext.insert(user)
    container.mainContext.insert(Call(callee: user))
    container.mainContext.insert(Call(callee: user))
    
    return NavigationStack {
        CalleeView(callee: user)
            .modelContainer(container)
    }
}
