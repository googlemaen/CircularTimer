import Foundation
import UIKit

final class TimerViewController: UIViewController {
	private enum TimerState {
		case stop
		case waitingForStart
		case pause
		case going
	}

	private let buttonsStack: UIStackView = {
		let stack = UIStackView()
		stack.axis = .horizontal
		stack.spacing = 32
		stack.distribution = .equalSpacing
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()

	private lazy var startButton: UIButton = {
		let button = UIButton(configuration: .borderedTinted())
		button.setTitle("Play", for: .normal)
		button.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
		return button
	}()

	private lazy var pauseButton: UIButton = {
		let button = UIButton(configuration: .borderedTinted())
		button.setTitle("Pause", for: .normal)
		button.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)
		return button
	}()

	private lazy var resetButton: UIButton = {
		let button = UIButton(configuration: .borderedTinted())
		button.setTitle("Reset", for: .normal)
		button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
		return button
	}()

	private let timerView = TimerView()

	private var timerModel = TimerModel(duration: 15, deltaTime: 0.01)
	private let timerService = TimerService()
	private var timerState: TimerState = .waitingForStart
	private var currentTimerViewAnimationState: TimerView.CurrentAnimationState?

	override func viewDidLoad() {
		super.viewDidLoad()
		configureUI()
		restartTimer()
	}

	private func configureUI() {
		view.backgroundColor = .secondarySystemBackground
		view.addSubview(buttonsStack)
		view.addSubview(timerView)
		buttonsStack.addArrangedSubview(startButton)
		buttonsStack.addArrangedSubview(pauseButton)
		buttonsStack.addArrangedSubview(resetButton)
		timerView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			timerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			timerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			timerView.widthAnchor.constraint(equalToConstant: 200),
			timerView.heightAnchor.constraint(equalToConstant: 200),
			buttonsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			buttonsStack.topAnchor.constraint(equalTo: timerView.bottomAnchor, constant: 32),
		])
	}

	private func updateViewWithCurrentTimer() {
		guard !timerModel.isFinished else {
			timerView.setTime(TimerView.Time(minutes: "00", seconds: "00", decimal: "00"))
			return
		}
		let integerPart = Int(timerModel.remainingTime.rounded(.down))
		let minutes = integerPart / 60
		let seconds = integerPart % 60
		let decimalPlaces = Int(((timerModel.remainingTime - CGFloat(integerPart)) * 100).rounded(.down))
		let format = "%.2d"
		timerView.setTime(TimerView.Time(
			minutes: String(format: format, minutes),
			seconds: String(format: format, seconds),
			decimal: String(format: format, decimalPlaces)
		))
	}

	private func restartTimer() {
		timerState = .going
		timerModel.reset()
		updateViewWithCurrentTimer()
		timerView.startAnimation(duration: timerModel.duration, initialProgress: 0, finalProgress: 1)
		launchTimerService()
	}

	private func launchTimerService() {
		timerService.start(duration: timerModel.deltaTime, repeats: true) { [weak self] in
			self?.timerTick()
		}
	}

	private func timerTick() {
		timerModel.tickTimer()
		if timerModel.isFinished {
			timerState = .stop
			timerService.stop()
		}
		updateViewWithCurrentTimer()
	}

	@objc private func playButtonTapped() {
		switch timerState {
		case .stop, .waitingForStart:
			restartTimer()
		case .pause:
			timerState = .going
			restoreTimerViewAfterPause()
			launchTimerService()
		case .going:
			break
		}
	}

	private func restoreTimerViewAfterPause() {
		let initialProgress: CGFloat
		if let currentTimerViewAnimationState {
			initialProgress = currentTimerViewAnimationState.progress
		} else {
			initialProgress = 1 - timerModel.remainingTime / timerModel.duration
		}
		timerView.startAnimation(duration: timerModel.remainingTime, initialProgress: initialProgress, finalProgress: 1)
	}

	@objc private func pauseButtonTapped() {
		guard timerState == .going else {
			return
		}
		timerState = .pause
		timerService.stop()
		currentTimerViewAnimationState = timerView.pauseAnimation()
	}

	@objc private func resetButtonTapped() {
		timerState = .waitingForStart
		timerService.stop()
		timerModel.reset()
		updateViewWithCurrentTimer()
		timerView.stopAnimation()
		timerView.setTimerProgress(0)
	}
}
