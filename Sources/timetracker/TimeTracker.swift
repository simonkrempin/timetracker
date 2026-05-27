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

    init() {
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    private static let minuteValues: [Double] = [20, 30, 45, 60, 90, 120, 180]

    @State private var remaining: Int = 0
    @State private var total: Int = 0
    @State private var durationMinutes: Double = 45
    @State private var timerRunning: Bool = false
    @State private var workingMode: WorkingMode = .sitting

    private var snappedIndex: Int {
        Self.minuteValues.enumerated().min(by: { abs($0.element - durationMinutes) < abs($1.element - durationMinutes) })!.offset
    }

    private static let sittingDurationOptions: [Int] = [
        20 * 60, 30 * 60, 45 * 60, 60 * 60, 90 * 60, 120 * 60, 180 * 60,
    ]
    private static let standingDurationOptions: [Int] = [
        8 * 60, 8 * 60, 8 * 60, 9 * 60, 10 * 60, 10 * 60, 10 * 60,
    ]
    private static let movementDurationOptions: [Int] = [
        2 * 60, 2 * 60, 2 * 60, 3 * 60, 4 * 60, 4 * 60, 5 * 60,
    ]

    private var currentDuration: Int {
        switch workingMode {
        case .sitting: Self.sittingDurationOptions[snappedIndex]
        case .standing: Self.standingDurationOptions[snappedIndex]
        case .moving: Self.movementDurationOptions[snappedIndex]
        }
    }

    private var formattedDuration: String {
        let minutes = currentDuration / 60
        if minutes < 60 {
            return "\(minutes) min"
        }
        let hours = minutes / 60
        let remainingMin = minutes % 60
        if remainingMin == 0 {
            return "\(hours) hour\(hours > 1 ? "s" : "")"
        }
        return "\(hours):\(String(format: "%02d", remainingMin)) hour"
    }

    private var remainingFormatted: String {
        if remaining >= 3600 {
            "\(remaining / 3600):\(String(format: "%02d", remaining % 3600 / 60))"
        } else {
            "\(remaining / 60):\(String(format: "%02d", remaining % 60))"
        }
    }

    private var progress: Double {
        guard total > 0 else { return 0 }
        return 1 - Double(remaining) / Double(total)
    }

    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some Scene {
        MenuBarExtra {
            VStack(alignment: .leading, spacing: 12) {
                Text("Time Tracker")
                    .font(.headline)

                Text(workingMode.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)

                if timerRunning {
                    Text(remainingFormatted)
                        .font(.title)
                        .monospacedDigit()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .contentTransition(.numericText())

                    ProgressView(value: progress)
                        .frame(maxWidth: .infinity)
                } else {
                    Text(formattedDuration)
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Slider(value: $durationMinutes, in: 20...180) { editing in
                            if !editing {
                                let closest = Self.minuteValues.min(by: { abs($0 - durationMinutes) < abs($1 - durationMinutes) })!
                                durationMinutes = closest
                            }
                        }
                        .frame(maxWidth: .infinity)
                }

                Button(timerRunning ? "Stop" : "Start") {
                    if timerRunning {
                        timerRunning = false
                        remaining = 0
                        total = 0
                    } else {
                        workingMode = .sitting
                        timerRunning = true
                        remaining = currentDuration
                        total = currentDuration
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.ultraThinMaterial)
            .onReceive(tick) { _ in
                guard timerRunning else { return }
                if remaining > 0 {
                    remaining -= 1
                } else {
                    switch workingMode {
                    case .sitting:
                        workingMode = .standing
                        remaining = Self.standingDurationOptions[snappedIndex]
                        total = remaining
                    case .standing:
                        workingMode = .moving
                        remaining = Self.movementDurationOptions[snappedIndex]
                        total = remaining
                    case .moving:
                        timerRunning = false
                        total = 0
                    }
                }
            }

        } label: {
            if timerRunning {
                Text(remainingFormatted)
                    .font(.caption)
                    .fontDesign(.monospaced)
            } else {
                Image(systemName: "timer")
            }
        }
        .menuBarExtraStyle(.window)
    }
}
