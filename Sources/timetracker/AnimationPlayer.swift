import AppKit
import Lottie
import SwiftUI

struct AnimationPlayer: NSViewRepresentable {
    @ObservedObject var queue: AnimationQueue

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: { queue.playNext() })
    }

    func makeNSView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView()
        view.contentMode = .scaleAspectFit
        view.backgroundBehavior = .pauseAndRestore
        context.coordinator.view = view
        return view
    }

    func updateNSView(_ animationView: LottieAnimationView, context: Context) {
        context.coordinator.update(item: queue.currentState)
    }

    @MainActor
    final class Coordinator {
        private let onComplete: () -> Void
        fileprivate weak var view: LottieAnimationView?
        private var currentItem: AnimationItem?
        private var isPlaying = false

        init(onComplete: @escaping () -> Void) {
            self.onComplete = onComplete
        }

        func update(item: AnimationItem?) {
            switch (isPlaying, item) {
            case (true, .some(let newItem)):
                guard let ci = currentItem else { return }
                if newItem.name == ci.name && ci.looping && !newItem.looping {
                    finishCurrentLoop(to: newItem)
                }

            case (false, .none):
                clearView()
                currentItem = nil

            case (false, .some(let newItem)):
                if newItem == currentItem {
                    return
                }
                start(item: newItem)

            default:
                break
            }
        }

        private func clearView() {
            isPlaying = false
            view?.stop()
            view?.animation = nil
        }

        private func finishCurrentLoop(to item: AnimationItem) {
            currentItem = item
            view?.loopMode = .playOnce
            let currentProgress = view?.currentProgress ?? 0
            view?.play(
                fromProgress: currentProgress,
                toProgress: 1,
                loopMode: .playOnce)
            { [weak self] _ in
                self?.onComplete()
            }
        }

        private func start(item: AnimationItem) {
            currentItem = item
            view?.animation = LottieAnimation.named(item.name, bundle: .module)
            view?.loopMode = item.looping ? .loop : .playOnce
            isPlaying = true
            view?.play { [weak self] _ in
                self?.isPlaying = false
                self?.onComplete()
            }
        }
    }
}