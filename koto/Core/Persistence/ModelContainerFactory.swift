//
//  ModelContainerFactory.swift
//  koto
//
//  Created on 26/11/25.
//

import Foundation
import SwiftData

/// Factory for creating ModelContainer with feature-specific schemas
/// Ensures complete separation between features
enum ModelContainerFactory {
    /// Creates a ModelContainer for Checklist feature only
    static func createChecklistContainer(storeURL: URL? = nil) throws -> ModelContainer {
        let schema = Schema([
            ChecklistList.self,
            ChecklistItem.self,
        ])
        
        let url = storeURL ?? URL.documentsDirectory.appending(path: "koto.checklist.store")
        let configuration = ModelConfiguration(schema: schema, url: url)
        
        return try ModelContainer(for: schema, configurations: [configuration])
    }
    
    /// Creates a ModelContainer for Notes feature only
    /// (To be implemented when Notes feature is added)
    // static func createNotesContainer(storeURL: URL? = nil) throws -> ModelContainer { ... }
    
    /// Creates a combined container for app initialization
    /// Uses separate stores per feature to maintain isolation
    static func createAppContainer() throws -> ModelContainer {
        // For now, only checklist feature exists
        return try createChecklistContainer()
    }
}

private extension URL {
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

