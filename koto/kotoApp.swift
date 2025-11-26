//
//  kotoApp.swift
//  koto
//
//  Created by Sahiba on 25/11/25.
//

import SwiftUI
import SwiftData

@main
struct kotoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ChecklistList.self,
            ChecklistItem.self,
        ])
        let storeURL = URL.documentsDirectory.appending(path: "koto.store")
        let modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)

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

private extension URL {
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
