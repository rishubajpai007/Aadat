//
//  FocusTimerAttributes.swift
//  Aadat
//
//  Created by Rishu Bajpai on 07/12/25.
//
import Foundation
import ActivityKit

// This struct defines the data that is passed between the Main App and the Widget Extension.
struct FocusTimerAttributes: ActivityAttributes {
    
    // ContentState defines the data that can change over time (dynamic data).
    // The Live Activity will automatically update its UI whenever this state changes.
    public struct ContentState: Codable, Hashable {
        
        // The estimatedEndTime is the only piece of dynamic data needed for a timer.
        // The iOS system uses this absolute future date to automatically calculate
        // and animate the countdown in the Dynamic Island and Lock Screen.
        var estimatedEndTime: Date
    }

    // Static attributes defined only once when the activity starts.
    // These values remain constant for the entire duration of the Live Activity.
    var totalDuration: Double
    var sessionName: String
}
