//
//  Item.swift
//  koto
//
//  Created by Sahiba on 25/11/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var title: String
    var createdAt: Date
    var isDone: Bool?
    
    init(title: String, createdAt: Date = .now, isDone: Bool = false) {
        self.title = title
        self.createdAt = createdAt
        self.isDone = isDone
    }
}

extension Item {
    var isCompleted: Bool {
        get { isDone ?? false }
        set { isDone = newValue }
    }
}
