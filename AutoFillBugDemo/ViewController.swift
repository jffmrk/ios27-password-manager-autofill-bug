import UIKit

final class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Home"

        let loginButton = UIButton.filled(title: "Login")
        loginButton.addTarget(self, action: #selector(openLogin), for: .touchUpInside)

        let createAccountButton = UIButton.filled(title: "Create Account")
        createAccountButton.addTarget(self, action: #selector(openCreateAccount), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [loginButton, createAccountButton])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func openLogin() {
        navigationController?.pushViewController(LoginViewController(), animated: true)
    }

    @objc private func openCreateAccount() {
        navigationController?.pushViewController(CreateAccountViewController(), animated: true)
    }
}
