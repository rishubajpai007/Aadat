//
//  ConcentrationModeModel.swift
//  Aadat
//
//  Created by Rishu Bajpai on 04/12/25.
//
import Foundation

struct ConcentrationModeModel {
    var timeRemaining: TimeInterval = 0
    var duration: TimeInterval = 0
    var isRunning = false
}

enum FocusDuration: Int, CaseIterable {
    case fifteen = 1
    case thirty = 30
    case fortyFive = 45
    case sixty = 60
    
    var minutes: Int {
        return self.rawValue
    }
}
