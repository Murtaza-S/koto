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
        do {
            return try ModelContainerFactory.createAppContainer()
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
