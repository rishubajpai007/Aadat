//
//  ConcentrationModeViewModel.swift
//  Aadat
//
//  Created by Rishu Bajpai on 04/12/25.
//
import Foundation
import Combine
import UIKit
import UserNotifications
import ActivityKit

class ConcentrationModeViewModel: ObservableObject {
    
    @Published private var model = ConcentrationModeModel()
    
    // Public accessors
    var timeRemaining: TimeInterval { model.timeRemaining }
    var duration: TimeInterval { model.duration }
    var isRunning: Bool { model.isRunning }
    
    private var timer: Timer?
    private var targetEndTime: Date?
    private let notificationId = "focus_timer_end"
    
    // Hold reference to the current Live Activity
    private var currentActivity: Activity<FocusTimerAttributes>?
    
    var progress: Double {
        duration > 0 ? (duration - timeRemaining) / duration : 0
    }
    
    var timeString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: timeRemaining) ?? "00:00"
    }
    
    // MARK: - Haptic Feedback
    
    func playSelectionHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    private func playSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    // MARK: - Live Activities (Lock Screen)
    
    private func startLiveActivity(duration: TimeInterval) {
        // 1. Check if Live Activities are supported (iOS 16.1+)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        // 2. Define the Attributes (Static Data)
        let attributes = FocusTimerAttributes(
            totalDuration: duration,
            sessionName: "Focus Session"
        )
        
        // 3. Define the Initial State (Dynamic Data)
        // Note: We use the absolute target date. The system handles the countdown logic.
        let targetDate = Date().addingTimeInterval(duration)
        let contentState = FocusTimerAttributes.ContentState(estimatedEndTime: targetDate)
        
        // 4. Request the Activity
        do {
            let activity = try Activity<FocusTimerAttributes>.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil // We are not using remote push updates
            )
            self.currentActivity = activity
            print("Live Activity Started: \(activity.id)")
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    private func endLiveActivity() {
        guard let activity = currentActivity else { return }
        
        // Update state to show 0 time immediately
        let finalState = FocusTimerAttributes.ContentState(estimatedEndTime: Date())
        
        Task {
            // Dismiss immediately
            await activity.end(using: finalState, dismissalPolicy: .immediate)
            self.currentActivity = nil
        }
    }
    
    // MARK: - Local Notifications
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
    
    private func scheduleNotification(seconds: TimeInterval) {
        guard seconds > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete!"
        content.body = "You successfully focused for \(Int(model.duration / 60)) minutes."
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
    }
    
    // MARK: - Lifecycle Handling
    
    func appDidBecomeActive() {
        guard isRunning, let endTime = targetEndTime else { return }
        let remaining = endTime.timeIntervalSinceNow
        
        if remaining <= 0 {
            model.timeRemaining = 0
            stopTimer()
            playSuccessHaptic()
        } else {
            model.timeRemaining = remaining
            startTicker()
        }
    }
    
    // MARK: - Timer Control
    
    func setDurationAndToggle(minutes: Int) {
        playSelectionHaptic()
        requestNotificationPermission()
        
        let newDuration = TimeInterval(minutes * 60)
        
        if isRunning && newDuration == duration {
            pauseTimer()
        } else {
            startTimer(duration: newDuration)
        }
    }
    
    private func startTimer(duration: TimeInterval) {
        model.duration = duration
        model.timeRemaining = duration
        model.isRunning = true
        targetEndTime = Date().addingTimeInterval(duration)
        
        scheduleNotification(seconds: duration)
        
        // Start Live Activity
        startLiveActivity(duration: duration)
        
        startTicker()
    }
    
    private func startTicker() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isRunning, let endTime = self.targetEndTime else { return }
            let remaining = endTime.timeIntervalSinceNow
            
            if remaining <= 0 {
                self.model.timeRemaining = 0
                self.stopTimer()
                self.playSuccessHaptic()
            } else {
                self.model.timeRemaining = remaining
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        model.isRunning = false
        model.timeRemaining = 0
        model.duration = 0
        targetEndTime = nil
        cancelNotification()
        
        // End Live Activity
        endLiveActivity()
    }
    
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        model.isRunning = false
        targetEndTime = nil
        cancelNotification()
        
        // End Live Activity (Since pausing complex logic is hard in Live Activities, we usually end it and restart on resume)
        endLiveActivity()
    }
    
    deinit {
        timer?.invalidate()
    }
}
