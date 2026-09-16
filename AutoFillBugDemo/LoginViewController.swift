import AuthenticationServices
import UIKit

final class LoginViewController: UIViewController {
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let faceIDButton = UIButton(type: .system)
    private let loginButton = UIButton(type: .system)
    private let keyboardFrameView = KeyboardFrameView()
    private let scrollView = UIScrollView()
    private var authorizationController: ASAuthorizationController?
    private var dateCheckedCredentials: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = "Login"
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textAlignment = .center

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        faceIDButton.setImage(UIImage(systemName: "faceid", withConfiguration: symbolConfig), for: .normal)
        faceIDButton.accessibilityLabel = "Face ID"
        faceIDButton.addTarget(self, action: #selector(faceIDTapped), for: .touchUpInside)
        faceIDButton.isHidden = true
        faceIDButton.setContentHuggingPriority(.required, for: .horizontal)
        faceIDButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        usernameField.placeholder = "Username"
        usernameField.borderStyle = .roundedRect
        usernameField.autocapitalizationType = .none
        usernameField.autocorrectionType = .no
        usernameField.textContentType = .username
        usernameField.keyboardType = .emailAddress
        usernameField.returnKeyType = .next
        usernameField.delegate = self

        let usernameRow = UIStackView(arrangedSubviews: [usernameField, faceIDButton])
        usernameRow.axis = .horizontal
        usernameRow.alignment = .fill
        usernameRow.spacing = 8

        passwordField.placeholder = "Password"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .password
        passwordField.returnKeyType = .done
        passwordField.delegate = self

        loginButton.setTitle("Login", for: .normal)
        loginButton.titleLabel?.font = .preferredFont(forTextStyle: .title2)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            usernameRow,
            passwordField,
            loginButton,
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        keyboardFrameView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboardFrameView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.addSubview(stack)

        // Lets the content view grow past the visible area so the stack can scroll,
        // while still hugging the stack when there is room to spare.
        let hugContent = stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        hugContent.priority = .defaultLow

        NSLayoutConstraint.activate([
            keyboardFrameView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardFrameView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardFrameView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: keyboardFrameView.topAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),

            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 16),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            hugContent,

            faceIDButton.widthAnchor.constraint(equalTo: faceIDButton.heightAnchor),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkCredentials()
    }

    private func checkCredentials() {
        let passwordProvider = ASAuthorizationPasswordProvider()
        let passwordRequest = passwordProvider.createRequest()
        let requests: [ASAuthorizationRequest] = [passwordRequest]

        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        self.authorizationController = authorizationController
        dateCheckedCredentials = Date()
        authorizationController.performRequests(options: .preferImmediatelyAvailableCredentials)
    }

    @objc private func faceIDTapped() {
        checkCredentials()
    }

    @objc private func loginTapped() {
        guard loginButton.isEnabled else { return }
        loginButton.isEnabled = false
        Task { await saveAndFinishLogin() }
    }

    private func saveAndFinishLogin() async {
        view.endEditing(true)
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        guard let presentingWindow = view.window else {
            loginButton.isEnabled = true
            return
        }

        do {
            try await CredentialManager.saveCredentials(
                username: username,
                password: password,
                anchor: presentingWindow
            )
            handleSuccess()
        } catch {
            loginButton.isEnabled = true
            print("Save Failed: \(error)")
            let alert = UIAlertController(
                title: "Save Failed",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    private func handleSuccess() {
        view.endEditing(true)
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        usernameField.text = ""
        passwordField.text = ""
        // wait for 1 second, display "logged in successfully" alert with ok button. On tap, dismiss the alert and pop to root view controller.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let alert = UIAlertController(
                title: "Logged in Successfully!",
                message: "• Username: \(username)\n• Password: \(password)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
            })
            self.present(alert, animated: true)
        }
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASPasswordCredential else { return }
        usernameField.text = credential.user
        passwordField.text = credential.password
        loginButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.handleSuccess()
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        // No immediately available credentials, or the user cancelled.
        print("authorizationController(didCompleteWithError): \(error)")

        let nsError = error as NSError
        if nsError.domain == ASAuthorizationError.errorDomain,
           nsError.code == ASAuthorizationError.canceled.rawValue
            || nsError.code == ASAuthorizationError.notInteractive.rawValue {
            let timeInterval = Date().timeIntervalSince(dateCheckedCredentials ?? Date())
            if timeInterval > 0.9 {
                // A longer interval indicates the Apple sign in sheet was displayed and cancelled
                // by the user. Show the Face ID button so they can get back to the sheet.
                faceIDButton.isHidden = false
            } else {
                // A short interval indicates there were no saved credentials to show.
                faceIDButton.isHidden = true
            }
        }
        usernameField.becomeFirstResponder()
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        view.window ?? ASPresentationAnchor()
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === usernameField {
            passwordField.becomeFirstResponder()
        } else if textField === passwordField {
            textField.resignFirstResponder()
            loginTapped()
        }
        return true
    }
}
