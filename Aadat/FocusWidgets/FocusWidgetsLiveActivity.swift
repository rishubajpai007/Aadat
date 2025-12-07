//
//  FocusWidgetsLiveActivity.swift
//  FocusWidgets
//
//  Created by Rishu Bajpai on 07/12/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity + Dynamic Island

struct FocusWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusTimerAttributes.self) { context in
            // MARK: - Lock Screen / Banner UI
            HStack(spacing: 12) {
                // Left: Icon and Title
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.indigo)

                        Text(context.attributes.sessionName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }

                    Text("Stay focused")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                // Right: Countdown Timer
                VStack(alignment: .trailing) {
                    Text(
                        timerInterval: Date()...context.state.estimatedEndTime,
                        countsDown: true
                    )
                    .monospacedDigit()
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                }
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.8))
            .activitySystemActionForegroundColor(.indigo)

        } dynamicIsland: { context in
            // MARK: - Dynamic Island
            DynamicIsland {
                // Expanded – Leading
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundColor(.indigo)
                }
//                .dynamicIslandVerticalPlacement(.center)

                // Expanded – Trailing
                DynamicIslandExpandedRegion(.trailing) {
                    Text(
                        timerInterval: Date()...context.state.estimatedEndTime,
                        countsDown: true
                    )
                    .monospacedDigit()
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.trailing)
                }
//                .dynamicIslandVerticalPlacement(.center)

                // Expanded – Bottom
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .center, spacing: 6) {
                        Text(context.attributes.sessionName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        ProgressView(
                            timerInterval: Date()...context.state.estimatedEndTime,
                            countsDown: true
                        )
                        .tint(.indigo)
                        .frame(height: 6)
                    }
                    .padding(.horizontal, 8)
                }

            } compactLeading: {
                // Compact leading
                Image(systemName: "brain.fill")
                    .foregroundColor(.indigo)
                    .padding(.leading, 4)

            } compactTrailing: {
                // Compact trailing – small countdown
                Text(
                    timerInterval: Date()...context.state.estimatedEndTime,
                    countsDown: true
                )
                .monospacedDigit()
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.yellow)
                .padding(.trailing, 4)

            } minimal: {
                // Minimal
                Image(systemName: "brain.fill")
                    .foregroundColor(.indigo)
            }
        }
    }
}

// MARK: - Previews

extension FocusTimerAttributes {
    fileprivate static var preview: FocusTimerAttributes {
        FocusTimerAttributes(
            totalDuration: 25 * 60,
            sessionName: "Focus Session"
        )
    }
}

extension FocusTimerAttributes.ContentState {
    fileprivate static var preview: FocusTimerAttributes.ContentState {
        FocusTimerAttributes.ContentState(
            estimatedEndTime: .now.addingTimeInterval(25 * 60)
        )
    }
}

#Preview("Live Activity", as: .content, using: FocusTimerAttributes.preview) {
    FocusWidgetsLiveActivity()
} contentStates: {
    FocusTimerAttributes.ContentState.preview
}
