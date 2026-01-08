import Foundation

struct ConcentrationModeModel {
    var timeRemaining: TimeInterval = 0
    var duration: TimeInterval = 0
    var isRunning = false
    var isStrictMode = true
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
