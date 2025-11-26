//
//  ListType.swift
//  koto
//
//  Created by ChatGPT on 26/11/25.
//

import Foundation

enum ListType: String, CaseIterable, Codable, Identifiable {
    case personal
    case work
    case shopping
    case custom

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .personal:
            "Personal"
        case .work:
            "Work"
        case .shopping:
            "Shopping"
        case .custom:
            "Custom"
        }
    }
}

