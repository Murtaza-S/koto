//
//  ListType.swift
//  koto
//
//  Created by ChatGPT on 26/11/25.
//

import Foundation

/// Represents the type of checklist list, determining reset behavior
enum ListType: String, CaseIterable, Codable, Identifiable {
    case daily
    case weekly
    case monthly
    case custom

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .daily:
            "Daily"
        case .weekly:
            "Weekly"
        case .monthly:
            "Monthly"
        case .custom:
            "Custom"
        }
    }

    /// Determines if this list type should auto-reset
    var supportsAutoReset: Bool {
        self != .custom
    }

    /// Returns the reset interval for this list type
    var resetInterval: Calendar.Component? {
        switch self {
        case .daily:
            return .day
        case .weekly:
            return .weekOfYear
        case .monthly:
            return .month
        case .custom:
            return nil
        }
    }
}

