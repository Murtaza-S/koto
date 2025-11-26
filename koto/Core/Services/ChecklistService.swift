//
//  ChecklistService.swift
//  koto
//
//  Created by ChatGPT on 26/11/25.
//

import Foundation
import SwiftData

/// Lightweight domain service that owns business logic for lists/items
/// so that SwiftUI views can stay declarative.
@MainActor
final class ChecklistService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    @discardableResult
    func ensureDefaultList(
        title: String = "My Checklist",
        type: ListType = .personal
    ) -> ChecklistList {
        if let existing = fetchNonArchivedList(matching: title) {
            return existing
        }

        return createList(title: title, type: type)
    }

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

    func toggleCompletion(_ item: ChecklistItem) {
        item.isCompleted.toggle()
        item.completionDate = item.isCompleted ? .now : nil
        item.updatedAt = .now
        if let list = item.list {
            touch(list)
        }
    }

    func delete(_ items: [ChecklistItem]) {
        guard !items.isEmpty else { return }
        let affectedLists = Set(items.compactMap(\.list))
        items.forEach(modelContext.delete)
        affectedLists.forEach(touch)
    }

    func deleteLists(_ lists: [ChecklistList]) {
        lists.forEach(modelContext.delete)
    }

    func markArchived(_ list: ChecklistList, archived: Bool = true) {
        list.isArchived = archived
        touch(list)
    }

    private func fetchNonArchivedList(matching title: String) -> ChecklistList? {
        let descriptor = FetchDescriptor<ChecklistList>(
            predicate: #Predicate { list in
                list.title == title && list.isArchived == false
            }
        )
        let lists = try? modelContext.fetch(descriptor)
        return lists?.first
    }

    private func touch(_ list: ChecklistList) {
        list.updatedAt = .now
    }
}

