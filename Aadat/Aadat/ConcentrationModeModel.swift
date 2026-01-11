import Foundation

struct ConcentrationModeModel {
    var timeRemaining: TimeInterval = 15 * 60
    var duration: TimeInterval = 15 * 60
    var isRunning = false
    var isStrictMode = false
}

enum FocusDuration: Int, CaseIterable {
    case fifteen = 15
    case thirty = 30
    case fortyFive = 45
    case sixty = 60
    
    var minutes: Int {
        return self.rawValue
    }
}
