import AppKit
import Combine
import SwiftUI

enum WorkingMode: String, CaseIterable {
    case sitting = "Sitting"
    case standing = "Standing"
    case moving = "Moving"
}

@main
struct TimeTrackerApp: App {

    private let notificationService: NotificationService = OSAScriptNotificationService()

    init() {
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    private static let workSessionOptionsMinutes: [Double] = [20, 30, 45, 60, 90, 120, 180]

    @State private var remainingPhaseSeconds: Int = 0
    @State private var totalPhaseDurationSeconds: Int = 0
    @State private var selectedSessionMinutes: Double = 45
    @State private var isTimerRunning: Bool = false
    @State private var currentWorkingMode: WorkingMode = .sitting

    private var selectedSessionIndex: Int {
        Self.workSessionOptionsMinutes.enumerated().min(by: {
            abs($0.element - selectedSessionMinutes) < abs($1.element - selectedSessionMinutes)
        })!.offset
    }

    private static let sittingPhaseDurationsSeconds: [Int] = [
        20 * 60, 30 * 60, 45 * 60, 60 * 60, 90 * 60, 120 * 60, 180 * 60,
    ]
    private static let standingPhaseDurationsSeconds: [Int] = [
        8 * 60, 8 * 60, 8 * 60, 9 * 60, 10 * 60, 10 * 60, 10 * 60,
    ]
    private static let movementPhaseDurationsSeconds: [Int] = [
        2 * 60, 2 * 60, 2 * 60, 3 * 60, 4 * 60, 4 * 60, 5 * 60,
    ]

    private var currentPhaseDurationSeconds: Int {
        switch currentWorkingMode {
        case .sitting: Self.sittingPhaseDurationsSeconds[selectedSessionIndex]
        case .standing: Self.standingPhaseDurationsSeconds[selectedSessionIndex]
        case .moving: Self.movementPhaseDurationsSeconds[selectedSessionIndex]
        }
    }

    private var formattedPhaseDuration: String {
        let minutes = currentPhaseDurationSeconds / 60
        if minutes < 60 {
            return "\(minutes) min"
        }

        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if remainingMinutes == 0 {
            return "\(hours) hour\(hours > 1 ? "s" : "")"
        }

        return "\(hours):\(String(format: "%02d", remainingMinutes)) hour"
    }

    private var formattedRemainingTime: String {
        if remainingPhaseSeconds >= 3600 {
            "\(remainingPhaseSeconds / 3600):\(String(format: "%02d", remainingPhaseSeconds % 3600 / 60))"
        } else {
            "\(remainingPhaseSeconds / 60):\(String(format: "%02d", remainingPhaseSeconds % 60))"
        }
    }

    private var phaseProgress: Double {
        guard totalPhaseDurationSeconds > 0 else { return 0 }
        return 1 - Double(remainingPhaseSeconds) / Double(totalPhaseDurationSeconds)
    }

    private let timerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some Scene {
        MenuBarExtra {
            VStack(alignment: .leading, spacing: 12) {
                Text(currentWorkingMode.rawValue)
                    .font(.headline)

                if isTimerRunning {
                    Text(formattedRemainingTime)
                        .font(.title)
                        .monospacedDigit()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .contentTransition(.numericText())

                    ProgressView(value: phaseProgress)
                        .frame(maxWidth: .infinity)
                } else {
                    Text(formattedPhaseDuration)
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Slider(value: $selectedSessionMinutes, in: 20...180) { editing in
                        if !editing {
                            let closestSessionMinutes = Self.workSessionOptionsMinutes.min(by: {
                                abs($0 - selectedSessionMinutes) < abs($1 - selectedSessionMinutes)
                            })!
                            selectedSessionMinutes = closestSessionMinutes
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                Button(isTimerRunning ? "Stop" : "Start") {
                    if isTimerRunning {
                        currentWorkingMode = .sitting
                        isTimerRunning = false
                        remainingPhaseSeconds = 0
                        totalPhaseDurationSeconds = 0
                    } else {
                        isTimerRunning = true
                        remainingPhaseSeconds = currentPhaseDurationSeconds
                        totalPhaseDurationSeconds = currentPhaseDurationSeconds
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.ultraThinMaterial)
            .onReceive(timerPublisher) { _ in
                guard isTimerRunning else { return }
                if remainingPhaseSeconds > 0 {
                    remainingPhaseSeconds -= 1
                } else {
                    switch currentWorkingMode {
                    case .sitting:
                        notificationService.post(
                            "Time to stand", "Stand up and stretch — your sitting session is done.")
                        currentWorkingMode = .standing
                        remainingPhaseSeconds = Self.standingPhaseDurationsSeconds[selectedSessionIndex]
                        totalPhaseDurationSeconds = remainingPhaseSeconds
                    case .standing:
                        notificationService.post(
                            "Time to move", "Take a short walk — your standing session is done.")
                        currentWorkingMode = .moving
                        remainingPhaseSeconds = Self.movementPhaseDurationsSeconds[selectedSessionIndex]
                        totalPhaseDurationSeconds = remainingPhaseSeconds
                    case .moving:
                        notificationService.post(
                            "Session complete", "Great work! Your full work cycle is done.")
                        isTimerRunning = false
                        currentWorkingMode = .sitting
                        totalPhaseDurationSeconds = 0
                    }
                }
            }

        } label: {
            if isTimerRunning {
                Text(formattedRemainingTime)
                    .font(.caption)
                    .fontDesign(.monospaced)
            } else {
                Image(systemName: "timer")
            }
        }
        .menuBarExtraStyle(.window)
    }
}
