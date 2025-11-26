//
//  ChecklistList.swift
//  koto
//
//  Created by ChatGPT on 26/11/25.
//

import Foundation
import SwiftData

@Model
final class ChecklistList {
    @Attribute(.unique) var id: UUID
    var title: String
    var type: ListType
    var color: String?
    var icon: String?
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool
    var lastResetDate: Date?

    @Relationship(deleteRule: .cascade)
    var items: [ChecklistItem] = []

    init(
        id: UUID = UUID(),
        title: String,
        type: ListType = .custom,
        color: String? = nil,
        icon: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        isArchived: Bool = false,
        lastResetDate: Date? = nil,
        items: [ChecklistItem] = []
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.color = color
        self.icon = icon
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
        self.lastResetDate = lastResetDate
        self.items = items
    }

    var activeItems: [ChecklistItem] {
        items
            .filter { !$0.isCompleted }
            .sorted { $0.order < $1.order }
    }

    var completedItems: [ChecklistItem] {
        items
            .filter(\.isCompleted)
            .sorted { lhs, rhs in
                let lhsDate = lhs.completionDate ?? lhs.updatedAt
                let rhsDate = rhs.completionDate ?? rhs.updatedAt
                return lhsDate > rhsDate
            }
    }
}

