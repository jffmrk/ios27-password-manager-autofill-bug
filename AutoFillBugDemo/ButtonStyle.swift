import UIKit

extension UIButton {
    static func filled(title: String) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.baseBackgroundColor = .systemBlue
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 14,
            leading: 20,
            bottom: 14,
            trailing: 20
        )
        configuration.titleTextAttributesTransformer =
            UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = .preferredFont(forTextStyle: .headline)
                return outgoing
            }
        return UIButton(configuration: configuration)
    }

    static func icon(systemName: String, accessibilityLabel: String) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(
            systemName: systemName,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        )
        configuration.baseForegroundColor = .systemBlue
        configuration.background.backgroundColor = .clear
        configuration.contentInsets = .zero

        let button = UIButton(configuration: configuration)
        button.accessibilityLabel = accessibilityLabel
        return button
    }
}
