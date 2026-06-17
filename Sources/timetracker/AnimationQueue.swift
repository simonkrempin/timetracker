import SwiftUI

@MainActor
final class AnimationQueue: ObservableObject {
    enum Predefined {
        case sitting
        case standing
        case moving
        case sittingToStanding
        case standingToMoving
        case movingToSitting

        var name: String {
            switch self {
            case .sitting:    "sitting"
            case .standing:   "standing"
            case .moving:     "moving"
            case .sittingToStanding: "sitting_to_standing"
            case .standingToMoving: "standing_to_moving"
            case .movingToSitting:  "moving_to_sitting"
            }
        }
    }

    @Published private(set) var currentState: AnimationItem?

    private var pending: [AnimationItem] = []

    func enqueue(_ animation: Predefined) {
        pending.append(AnimationItem(name: animation.name, looping: false))

        if currentState == nil {
            playNext()
        } else if currentState!.looping {
            currentState = AnimationItem(name: currentState!.name, looping: false)
        }
    }

    func playNext() {
        guard !pending.isEmpty else {
            currentState = nil
            return
        }

        let next = pending.removeFirst()
        currentState = AnimationItem(
            name: next.name,
            looping: pending.isEmpty
        )
    }
}
