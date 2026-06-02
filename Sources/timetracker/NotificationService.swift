import AppKit
import UserNotifications

protocol NotificationService {
    func post(title: String, body: String)
}

struct OSAScriptNotificationService: NotificationService {
    func post(title: String, body: String) {
        let escapedTitle = title.replacingOccurrences(of: "\\", with: "\\\\\\\\").replacingOccurrences(of: "\"", with: "\\\\\"")
        let escapedBody = body.replacingOccurrences(of: "\\", with: "\\\\\\\\").replacingOccurrences(of: "\"", with: "\\\\\"")
        let script = "display notification \"\(escapedBody)\" with title \"\(escapedTitle)\" sound name \"default\""
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]
        try? process.run()
        process.waitUntilExit()
    }
}

struct UNNotificationService: NotificationService {
    func post(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}