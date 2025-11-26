//
//  ChecklistService.swift
//  koto
//
//  Created on 26/11/25.
//

import Foundation
import SwiftData

/// Domain service for Checklist feature
/// Handles all business logic for ChecklistList and ChecklistItem
/// 
/// **Architecture Rules:**
/// - Only works with ChecklistList and ChecklistItem models
/// - No dependencies on Notes feature models
/// - All queries are isolated to Checklist models
@MainActor
final class ChecklistService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - List Operations
    
    /// Creates a new checklist list
    @discardableResult
    func createList(
        title: String,
        type: ListType = .custom,
        color: String? = nil,
        icon: String? = nil
    ) -> ChecklistList {
        let list = ChecklistList(
            title: title,
            type: type,
            color: color,
            icon: icon
        )
        modelContext.insert(list)
        return list
    }
    
    /// Ensures a default list exists, creating one if needed
    @discardableResult
    func ensureDefaultList(
        title: String = "My Checklist",
        type: ListType = .custom
    ) -> ChecklistList {
        if let existing = fetchNonArchivedList(matching: title) {
            return existing
        }
        return createList(title: title, type: type)
    }
    
    /// Updates list properties
    func updateList(
        _ list: ChecklistList,
        title: String? = nil,
        type: ListType? = nil,
        color: String? = nil,
        icon: String? = nil
    ) {
        if let title = title {
            list.title = title
        }
        if let type = type {
            list.type = type
        }
        if let color = color {
            list.color = color
        }
        if let icon = icon {
            list.icon = icon
        }
        touch(list)
    }
    
    /// Archives or unarchives a list
    func markArchived(_ list: ChecklistList, archived: Bool = true) {
        list.isArchived = archived
        touch(list)
    }
    
    /// Deletes one or more lists (cascade deletes items)
    func deleteLists(_ lists: [ChecklistList]) {
        lists.forEach(modelContext.delete)
    }
    
    /// Fetches all non-archived lists
    func fetchActiveLists() -> [ChecklistList] {
        let descriptor = FetchDescriptor<ChecklistList>(
            predicate: #Predicate { list in
                list.isArchived == false
            },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Fetches a list by ID
    func fetchList(id: UUID) -> ChecklistList? {
        let descriptor = FetchDescriptor<ChecklistList>(
            predicate: #Predicate { list in
                list.id == id
            }
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    // MARK: - Item Operations
    
    /// Adds a new item to a list
    @discardableResult
    func addItem(text: String, to list: ChecklistList) -> ChecklistItem {
        let nextOrder = (list.items.map(\.order).max() ?? 0) + 1
        let item = ChecklistItem(
            text: text,
            order: nextOrder,
            list: list
        )
        modelContext.insert(item)
        list.items.append(item)
        touch(list)
        return item
    }
    
    /// Updates an item's text
    func updateItem(_ item: ChecklistItem, text: String) {
        item.text = text
        item.updatedAt = .now
        if let list = item.list {
            touch(list)
        }
    }
    
    /// Toggles completion status of an item
    func toggleCompletion(_ item: ChecklistItem) {
        item.isCompleted.toggle()
        item.completionDate = item.isCompleted ? .now : nil
        item.updatedAt = .now
        if let list = item.list {
            touch(list)
        }
    }
    
    /// Marks an item as completed
    func markCompleted(_ item: ChecklistItem, completed: Bool = true) {
        item.isCompleted = completed
        item.completionDate = completed ? .now : nil
        item.updatedAt = .now
        if let list = item.list {
            touch(list)
        }
    }
    
    /// Updates item order
    func updateItemOrder(_ item: ChecklistItem, order: Int) {
        item.order = order
        item.updatedAt = .now
        if let list = item.list {
            touch(list)
        }
    }
    
    /// Deletes one or more items
    func deleteItems(_ items: [ChecklistItem]) {
        guard !items.isEmpty else { return }
        let affectedLists = Set(items.compactMap(\.list))
        items.forEach(modelContext.delete)
        affectedLists.forEach(touch)
    }
    
    // MARK: - Reset Operations
    
    /// Checks if a list needs to be reset based on its type
    func shouldResetList(_ list: ChecklistList) -> Bool {
        guard list.type.supportsAutoReset,
              let resetInterval = list.type.resetInterval else {
            return false
        }
        
        guard let lastReset = list.lastResetDate else {
            return true // Never reset, should reset now
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        switch resetInterval {
        case .day:
            return !calendar.isDate(lastReset, inSameDayAs: now)
        case .weekOfYear:
            return !calendar.isDate(lastReset, equalTo: now, toGranularity: .weekOfYear)
        case .month:
            return !calendar.isDate(lastReset, equalTo: now, toGranularity: .month)
        default:
            return false
        }
    }
    
    /// Resets a list by marking all items as incomplete
    func resetList(_ list: ChecklistList) {
        guard list.type.supportsAutoReset else { return }
        
        list.items.forEach { item in
            item.isCompleted = false
            item.completionDate = nil
            item.updatedAt = .now
        }
        
        list.lastResetDate = .now
        touch(list)
    }
    
    /// Checks and resets all lists that need resetting
    func checkAndResetLists() {
        let activeLists = fetchActiveLists()
        activeLists.filter(shouldResetList).forEach(resetList)
    }
    
    // MARK: - Private Helpers
    
    private func fetchNonArchivedList(matching title: String) -> ChecklistList? {
        let descriptor = FetchDescriptor<ChecklistList>(
            predicate: #Predicate { list in
                list.title == title && list.isArchived == false
            }
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    private func touch(_ list: ChecklistList) {
        list.updatedAt = .now
    }
}
