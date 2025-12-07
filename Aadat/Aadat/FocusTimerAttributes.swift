//
//  FocusTimerAttributes.swift
//  Aadat
//
//  Created by Rishu Bajpai on 07/12/25.
//
import Foundation
import ActivityKit

struct FocusTimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var estimatedEndTime: Date
    }

    var totalDuration: Double
    var sessionName: String
}
