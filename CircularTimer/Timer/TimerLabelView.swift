import UIKit

final class TimerLabelView: UIStackView {
	private let minutesLabel = UILabel()
	private let firstDividerLabel = UILabel()
	private let secondsLabel = UILabel()
	private let secondDividerLabel = UILabel()
	private let decimalPlatesLabel = UILabel()

	override init(frame: CGRect) {
		super.init(frame: frame)
		configureUI()
	}

	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setMinutes(_ minutes: String, seconds: String, decimal: String) {
		minutesLabel.text = minutes
		secondsLabel.text = seconds
		decimalPlatesLabel.text = decimal
	}

	private func configureUI() {
		axis = .horizontal
		spacing = 0
		distribution = .equalSpacing
		translatesAutoresizingMaskIntoConstraints = false
		[minutesLabel, firstDividerLabel, secondsLabel, secondDividerLabel, decimalPlatesLabel].forEach { label in
			addArrangedSubview(label)
			label.translatesAutoresizingMaskIntoConstraints = false
			label.font = .systemFont(ofSize: 24, weight: .medium)
			label.textColor = .black
			label.textAlignment = .center
		}
		firstDividerLabel.text = ":"
		secondDividerLabel.text = ":"
		let componentSize = CGSize(width: 32, height: 28)
		let dividerWidth: CGFloat = 10
		NSLayoutConstraint.activate([
			heightAnchor.constraint(equalToConstant: componentSize.height),
			minutesLabel.widthAnchor.constraint(equalToConstant: componentSize.width),
			firstDividerLabel.widthAnchor.constraint(equalToConstant: dividerWidth),
			secondsLabel.widthAnchor.constraint(equalToConstant: componentSize.width),
			secondDividerLabel.widthAnchor.constraint(equalToConstant: dividerWidth),
			decimalPlatesLabel.widthAnchor.constraint(equalToConstant: componentSize.width)
		])
	}
}
