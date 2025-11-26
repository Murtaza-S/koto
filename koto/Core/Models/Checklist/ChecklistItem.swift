//
//  ChecklistItem.swift
//  koto
//
//  Created by ChatGPT on 26/11/25.
//

import Foundation
import SwiftData

@Model
final class ChecklistItem {
    @Attribute(.unique) var id: UUID
    var text: String
    var isCompleted: Bool
    var completionDate: Date?
    var order: Int
    var createdAt: Date
    var updatedAt: Date

    var list: ChecklistList?

    init(
        id: UUID = UUID(),
        text: String,
        isCompleted: Bool = false,
        completionDate: Date? = nil,
        order: Int,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        list: ChecklistList? = nil
    ) {
        self.id = id
        self.text = text
        self.isCompleted = isCompleted
        self.completionDate = completionDate
        self.order = order
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.list = list
    }
}

