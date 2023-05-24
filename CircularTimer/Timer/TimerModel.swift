import Foundation

struct TimerModel {
	let duration: CGFloat
	private(set) var remainingTime: CGFloat
	let deltaTime: CGFloat

	var isFinished: Bool {
		remainingTime <= 0
	}

	init(duration: CGFloat, deltaTime: CGFloat) {
		self.duration = duration
		self.remainingTime = duration
		self.deltaTime = deltaTime
	}

	mutating func tickTimer() {
		remainingTime -= deltaTime
	}

	mutating func reset() {
		remainingTime = duration
	}
}
