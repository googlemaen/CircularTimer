import UIKit

final class TimerView: UIView {
	struct Time {
		let minutes: String
		let seconds: String
		let decimal: String
	}

	struct CurrentAnimationState {
		let progress: CGFloat
	}

	private static let lineWidth: CGFloat = 20

	private let backgroundCircleLayer: CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.strokeStart = 0
		layer.strokeEnd = 1
		layer.strokeColor = UIColor.systemGray5.cgColor
		layer.fillColor = UIColor.clear.cgColor
		layer.lineWidth = lineWidth
		return layer
	}()

	private let timerCircleLayer: CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.strokeStart = 0
		layer.strokeEnd = 1
		layer.strokeColor = UIColor.green.cgColor
		layer.fillColor = UIColor.clear.cgColor
		layer.lineWidth = lineWidth
		return layer
	}()

	private let timerLabelView = TimerLabelView()

	override init(frame: CGRect) {
		super.init(frame: frame)
		configureUI()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		let path = UIBezierPath(
			arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
			radius: frame.width / 2,
			startAngle: 0,
			endAngle: 2 * .pi,
			clockwise: true
		)
		backgroundCircleLayer.path = path.cgPath
		timerCircleLayer.frame = bounds
		timerCircleLayer.transform = CATransform3DMakeRotation(.pi / 2, 0, 0, -1)
		timerCircleLayer.path = path.cgPath
	}

	func setTime(_ time: Time) {
		timerLabelView.setMinutes(time.minutes, seconds: time.seconds, decimal: time.decimal)
	}

	func setTimerProgress(_ progress: CGFloat) {
		timerCircleLayer.strokeStart = progress
	}

	func startAnimation(duration: CGFloat, initialProgress: CGFloat, finalProgress: CGFloat) {
		let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeStart))
		timerCircleLayer.strokeStart = finalProgress
		animation.fromValue = initialProgress
		animation.toValue = finalProgress
		animation.duration = duration
		timerCircleLayer.add(animation, forKey: "stroke_animation")
	}

	func pauseAnimation() -> CurrentAnimationState {
		let strokeStart = timerCircleLayer.presentation()?.strokeStart ?? 0
		timerCircleLayer.strokeStart = strokeStart
		stopAnimation()
		return CurrentAnimationState(progress: strokeStart)
	}

	func stopAnimation() {
		timerCircleLayer.removeAllAnimations()
	}

	private func configureUI() {
		layer.addSublayer(backgroundCircleLayer)
		layer.addSublayer(timerCircleLayer)
		addSubview(timerLabelView)
		NSLayoutConstraint.activate([
			timerLabelView.centerYAnchor.constraint(equalTo: centerYAnchor),
			timerLabelView.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
	}
}
