//
//  HabitUnit.swift
//  Aadat
//
//  Created by Rishu Bajpai on 07/12/25.
//

import Foundation

enum HabitUnit: String, Codable, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    
    var displayName: String {
        switch self {
        case .day: return "Daily"
        case .week: return "Weekly"
        case .month: return "Monthly"
        }
    }
}
