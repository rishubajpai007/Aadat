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

class ConcentrationModeViewModel: ObservableObject {
    
    @Published private var model = ConcentrationModeModel()
    var timeRemaining: TimeInterval { model.timeRemaining }
    var duration: TimeInterval { model.duration }
    var isRunning: Bool { model.isRunning }
    
    private var timer: Timer?
    private var targetEndTime: Date?
    private let notificationId = "focus_timer_end"
    
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
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleNotification(seconds: TimeInterval) {
        guard seconds > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete!"
        content.body = "You successfully focused for \(Int(model.duration / 60)) minutes."
        content.sound = UNNotificationSound.default
        content.interruptionLevel = .timeSensitive
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
    }
    
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
    }
    
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        model.isRunning = false
        targetEndTime = nil
        cancelNotification()
    }
    
    deinit {
        timer?.invalidate()
    }
}
