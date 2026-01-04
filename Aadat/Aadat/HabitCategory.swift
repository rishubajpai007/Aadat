import Foundation
import SwiftUI

enum HabitCategory: String, Codable, CaseIterable {
    case sports = "Sports"
    case health = "Health"
    case work = "Work"
    case food = "Food"
    case finance = "Finance"
    case yoga = "Yoga"
    case social = "Social"
    case fun = "Fun"
    case outdoor = "Outdoor"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .sports: return "🏀"
        case .health: return "🍎"
        case .work: return "💼"
        case .food: return "🍕"
        case .finance: return "💰"
        case .yoga: return "🧘‍♀️"
        case .social: return "👥"
        case .fun: return "🎉"
        case .outdoor: return "🌳"
        case .other: return "✨"
        }
    }
    
    var color: Color {
        switch self {
        case .sports: return .blue
        case .health: return .green
        case .work: return .indigo
        case .food: return .orange
        case .finance: return .mint
        case .yoga: return .purple
        case .social: return .cyan
        case .fun: return .pink
        case .outdoor: return .teal
        case .other: return .gray
        }
    }
}
