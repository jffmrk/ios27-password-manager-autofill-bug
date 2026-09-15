import UIKit

class KeyboardFrameView: UIView {
    private let notificationCenter = NotificationCenter.default

    private var keyboardHeight: CGFloat = 0 {
        didSet {
            guard self.keyboardHeight != oldValue else {
                return
            }

            self.invalidateIntrinsicContentSize()
            self.superview?.setNeedsLayout()
            self.superview?.layoutIfNeeded()
            self.onHeightChange?(self.keyboardHeight)
        }
    }

    var onHeightChange: ((CGFloat) -> Void)?

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.buildView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: self.keyboardHeight)
    }

    func buildView() {
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        self.notificationCenter.addObserver(self, selector: #selector(self.keyboardShown(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        self.notificationCenter.addObserver(self, selector: #selector(self.keyboardDismissed(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardShown(_ notification: Notification) {
        guard let info: [AnyHashable: Any] = notification.userInfo, let keyboardRect: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        let windowRect = self.convert(self.bounds, to: nil)
        let actualHeight = windowRect.maxY - keyboardRect.origin.y
        self.adjustForKeyboard(height: actualHeight, from: notification)
    }

    @objc func keyboardDismissed(_ notification: Notification) {
        self.adjustForKeyboard(height: 0, from: notification)
    }

    private func adjustForKeyboard(height: CGFloat, from notification: Notification) {
        guard let info: [AnyHashable: Any] = notification.userInfo else { return }

        let duration: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)

        guard height != self.keyboardHeight else {
            return
        }

        UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: {
            self.keyboardHeight = height
        }, completion: nil)
    }
}
