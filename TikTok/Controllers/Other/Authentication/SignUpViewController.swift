//
//  SignUpViewController.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import UIKit
import SafariServices

class SignUpViewController: UIViewController, UITextFieldDelegate {

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()

        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "logo")
        return imageView
    }()

    private let usernameField = AuthTextField(type: .username)
    private let emailField = AuthTextField(type: .email)
    private let passwordField = AuthTextField(type: .password)

    private let signUpButton = AuthButton(type: .signUp, title: nil)
    private let termsOfServiceButton = AuthButton(type: .plain, title: "Terms of Service")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        addSubviews()
        configureFields()
        configureButtons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        usernameField.becomeFirstResponder()
    }

    func addSubviews() {
        view.addSubview(logoImageView)
        view.addSubview(usernameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
        view.addSubview(termsOfServiceButton)
    }

    func configureButtons() {
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        termsOfServiceButton.addTarget(self, action: #selector(didTapTermsOfService), for: .touchUpInside)
    }

    func configureFields() {
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self

        let toolbar = UIToolbar(frame: CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: 50
        ))
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapKeyboardDone)),
        ]
        toolbar.sizeToFit()
        emailField.inputAccessoryView = toolbar
        passwordField.inputAccessoryView = toolbar
        usernameField.inputAccessoryView = toolbar
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let imageSize: CGFloat = 100
        logoImageView.frame = CGRect(
            x: (view.width - imageSize) / 2,
            y: view.safeAreaInsets.top + 5,
            width: imageSize,
            height: imageSize
        )
        usernameField.frame = CGRect(
            x: 20,
            y: logoImageView.bottom + 20,
            width: view.width - 40,
            height: 55
        )
        emailField.frame = CGRect(
            x: 20,
            y: usernameField.bottom + 20,
            width: view.width - 40,
            height: 55
        )
        passwordField.frame = CGRect(
            x: 20,
            y: emailField.bottom + 15,
            width: view.width - 40,
            height: 55
        )
        signUpButton.frame = CGRect(
            x: 20,
            y: passwordField.bottom + 20,
            width: view.width - 40,
            height: 55
        )
        termsOfServiceButton.frame = CGRect(
            x: 20,
            y: signUpButton.bottom + 40,
            width: view.width - 40,
            height: 55
        )

    }

    // MARK: - Button actions

    @objc func didTapKeyboardDone() {
        usernameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }

    @objc func didTapSignUp() {
        didTapKeyboardDone()

        guard let username = usernameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              !username.contains(" "),
              !username.contains("."),
              password.count >= 6 else {

            let alert = UIAlertController(
                title: "Woops",
                message: "Please make sure to enter a valid username, email address, and password. Your password must be at least 6 characters long.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return

        }

        AuthManager.shared.signUp(with: username, emailAddress: email, password: password) { signUpSuccess in

        }
    }

    @objc func didTapTermsOfService() {
        didTapKeyboardDone()

        guard let url = URL(string: "https://www.tiktok.com/legal/terms-of-service") else  {
            return
        }

        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }

}
