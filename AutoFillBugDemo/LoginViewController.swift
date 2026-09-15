import AuthenticationServices
import UIKit

final class LoginViewController: UIViewController {
    private let usernameField = UITextField()
    private let passwordField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = "Login"
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textAlignment = .center

        usernameField.placeholder = "Username"
        usernameField.borderStyle = .roundedRect
        usernameField.autocapitalizationType = .none
        usernameField.autocorrectionType = .no
        usernameField.textContentType = .username
        usernameField.keyboardType = .emailAddress

        passwordField.placeholder = "Password"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .password

        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Login", for: .normal)
        loginButton.titleLabel?.font = .preferredFont(forTextStyle: .title2)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            usernameField,
            passwordField,
            loginButton,
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func loginTapped() {
        Task { await saveCredentials() }
    }

    private func saveCredentials() async {
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        let credentialTitle = "AutoFill Bug Demo"

        guard let presentingWindow = view.window else { return }

        do {
            let credential = ASPasswordCredential(user: username, password: password)
            let scope = ASAutoFillURLScope(scheme: .https, host: Constants.host)
            try await ASCredentialDataManager().save(password: credential,
                                                     for: scope,
                                                     title: credentialTitle,
                                                     anchor: presentingWindow)
        } catch {
            let alert = UIAlertController(
                title: "Save Failed",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
