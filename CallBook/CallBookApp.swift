//
//  CallBookApp.swift
//  CallBook
//
//  Created by M on 29/11/2023.
//

import SwiftUI
import SwiftData

@main
struct CallBookApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Callee.self,
            Call.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
