import Foundation

final class TimerService {
	private var timer: Timer?

	func start(duration: CGFloat, repeats: Bool, completion: @escaping () -> Void) {
		stop()
		timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: repeats, block: { _ in
			completion()
		})
	}

	func stop() {
		timer?.invalidate()
		timer = nil
	}
}
