import UIKit

final class CreateAccountViewController: UIViewController {
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let confirmPasswordField = UITextField()
    private let keyboardFrameView = KeyboardFrameView()
    private let scrollView = UIScrollView()
    private var isSubmitting = false
    private var passwordSubmitWorkItem: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = "Create Account"
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textAlignment = .center

        usernameField.placeholder = "Username"
        usernameField.borderStyle = .roundedRect
        usernameField.autocapitalizationType = .none
        usernameField.autocorrectionType = .no
        usernameField.textContentType = .username
        usernameField.keyboardType = .emailAddress
        usernameField.returnKeyType = .next
        usernameField.delegate = self
        usernameField.text = "Bob"

        passwordField.placeholder = "Create Password"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .newPassword
        passwordField.returnKeyType = .next
        passwordField.delegate = self
        passwordField.addTarget(self, action: #selector(passwordFieldsDidChange), for: .editingChanged)

        confirmPasswordField.placeholder = "Confirm Password"
        confirmPasswordField.borderStyle = .roundedRect
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.textContentType = .newPassword
        confirmPasswordField.returnKeyType = .done
        confirmPasswordField.delegate = self
        confirmPasswordField.addTarget(self, action: #selector(passwordFieldsDidChange), for: .editingChanged)

        let createAccountButton = UIButton(type: .system)
        createAccountButton.setTitle("Create Account", for: .normal)
        createAccountButton.titleLabel?.font = .preferredFont(forTextStyle: .title2)
        createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            usernameField,
            passwordField,
            confirmPasswordField,
            createAccountButton,
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
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordField.becomeFirstResponder()
    }

    @objc private func passwordFieldsDidChange() {
        passwordSubmitWorkItem?.cancel()

        let username = usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField.text ?? ""
        let confirm = confirmPasswordField.text ?? ""
        guard !username.isEmpty, !password.isEmpty, password == confirm else { return }

        view.endEditing(true)

        let work = DispatchWorkItem { [weak self] in
            let username = self?.usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !username.isEmpty else { return }
            self?.createAccountTapped()
        }
        passwordSubmitWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: work)
    }

    @objc private func createAccountTapped() {
        guard !isSubmitting else { return }
        isSubmitting = true
        Task { await saveAndFinishCreateAccount() }
    }

    private func saveAndFinishCreateAccount() async {
        view.endEditing(true)
        let username = usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField.text ?? ""
        let confirmPassword = confirmPasswordField.text ?? ""

        if username.isEmpty {
            isSubmitting = false
            presentSimpleAlert(title: "Missing Username", message: "Please enter a username.")
            return
        }
        if password.isEmpty || confirmPassword.isEmpty {
            isSubmitting = false
            presentSimpleAlert(title: "Missing Password", message: "Please enter and confirm a password.")
            return
        }
        if password != confirmPassword {
            isSubmitting = false
            presentSimpleAlert(title: "Passwords Do Not Match", message: "Please make sure both password fields match.")
            return
        }

        guard let presentingWindow = view.window else {
            isSubmitting = false
            return
        }

        do {
            try await CredentialManager.saveCredentials(
                username: username,
                password: password,
                anchor: presentingWindow
            )
            let alert = UIAlertController(
                title: "Account Created",
                message: "Your account was created.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
            })
            present(alert, animated: true)
        } catch {
            isSubmitting = false
            print("Save Failed: \(error)")
            presentSimpleAlert(title: "Save Failed", message: error.localizedDescription)
        }
    }

    private func presentSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === usernameField {
            passwordField.becomeFirstResponder()
        } else if textField === passwordField {
            confirmPasswordField.becomeFirstResponder()
        } else if textField === confirmPasswordField {
            textField.resignFirstResponder()
            createAccountTapped()
        }
        return true
    }
}
