import Foundation
import Combine
import UIKit
import UserNotifications
import ActivityKit
import CoreMotion

class ConcentrationModeViewModel: ObservableObject {
    
    @Published private var model = ConcentrationModeModel()
    @Published var isFaceDown = false
    
    var timeRemaining: TimeInterval { model.timeRemaining }
    var duration: TimeInterval { model.duration }
    var isRunning: Bool { model.isRunning }
    
    private var timer: Timer?
    private var targetEndTime: Date?
    private let notificationId = "focus_timer_end"
    private let motionManager = CMMotionManager()
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
    
    init() {
        startMonitoringMotion()
    }
    
    // MARK: - Motion Detection (Flip logic)
    
    private func startMonitoringMotion() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 0.5
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
            guard let self = self, let motion = motion else { return }
            
            let isDown = motion.gravity.z > 0.9
            
            if isDown != self.isFaceDown {
                self.isFaceDown = isDown
                self.handleOrientationChange()
            }
        }
    }
    
    private func handleOrientationChange() {
        guard duration > 0 else { return }
        
        if isFaceDown {
            if !isRunning && timeRemaining > 0 {
                startTimer(duration: duration, remaining: timeRemaining)
            }
        } else {
            if isRunning {
                pauseTimer()
            }
        }
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
    
    // MARK: - Live Activities
    
    private func startLiveActivity(duration: TimeInterval) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        for activity in Activity<FocusTimerAttributes>.activities {
            Task { await activity.end(dismissalPolicy: .immediate) }
        }
        
        let attributes = FocusTimerAttributes(totalDuration: duration, sessionName: "Focus Session")
        let targetDate = Date().addingTimeInterval(timeRemaining)
        let contentState = FocusTimerAttributes.ContentState(estimatedEndTime: targetDate)
        
        do {
            let activity = try Activity<FocusTimerAttributes>.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            self.currentActivity = activity
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    private func endLiveActivity() {
        if let activity = currentActivity {
            let finalState = FocusTimerAttributes.ContentState(estimatedEndTime: Date())
            Task { await activity.end(using: finalState, dismissalPolicy: .immediate) }
            self.currentActivity = nil
        }
        
        for activity in Activity<FocusTimerAttributes>.activities {
            Task { await activity.end(dismissalPolicy: .immediate) }
        }
    }
    
    // MARK: - Lifecycle Handling
    
    func appDidBecomeActive() {
        // If it was running and flipped, sync. If lifted, it should remain paused.
        guard isRunning, isFaceDown, let endTime = targetEndTime else { return }
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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        
        let newDuration = TimeInterval(minutes * 60)
        
        stopTimer()
        model.duration = newDuration
        model.timeRemaining = newDuration
        
        if isFaceDown {
            startTimer(duration: newDuration, remaining: newDuration)
        }
    }
    
    private func startTimer(duration: TimeInterval, remaining: TimeInterval) {
        model.isRunning = true
        targetEndTime = Date().addingTimeInterval(remaining)
        
        scheduleNotification(seconds: remaining)
        startLiveActivity(duration: duration)
        startTicker()
        
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
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
        endLiveActivity()
    }
    
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        model.isRunning = false
        targetEndTime = nil
        cancelNotification()
        endLiveActivity()
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func scheduleNotification(seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete!"
        content.body = "Well done!"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
    }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
        timer?.invalidate()
    }
}
