import UIKit

final class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Home"

        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Login", for: .normal)
        loginButton.titleLabel?.font = .preferredFont(forTextStyle: .title2)
        loginButton.addTarget(self, action: #selector(openLogin), for: .touchUpInside)

        let createAccountButton = UIButton(type: .system)
        createAccountButton.setTitle("Create Account", for: .normal)
        createAccountButton.titleLabel?.font = .preferredFont(forTextStyle: .title2)
        createAccountButton.addTarget(self, action: #selector(openCreateAccount), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [loginButton, createAccountButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
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
