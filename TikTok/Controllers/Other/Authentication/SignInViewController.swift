//
//  SignInViewController.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import UIKit
import SafariServices

class SignInViewController: UIViewController, UITextFieldDelegate {

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()

        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "logo")
        return imageView
    }()

    private let emailField = AuthTextField(type: .email)

    private let passwordField = AuthTextField(type: .password)

    private let signInButton = AuthButton(type: .signIn, title: nil)
    private let forgotPassword = AuthButton(type: .plain, title: "Forgot Password?")
    private let signUpButton = AuthButton(type: .plain, title: "New User? Create Account")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Sign In"
        addSubviews()
        configureFields()
        configureButtons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        emailField.becomeFirstResponder()
    }

    func addSubviews() {
        view.addSubview(logoImageView)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signInButton)
        view.addSubview(forgotPassword)
        view.addSubview(signUpButton)
    }

    func configureButtons() {
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        forgotPassword.addTarget(self, action: #selector(didTapForgotPassword), for: .touchUpInside)
    }

    func configureFields() {
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
        emailField.frame = CGRect(
            x: 20,
            y: logoImageView.bottom + 20,
            width: view.width - 40,
            height: 55
        )
        passwordField.frame = CGRect(
            x: 20,
            y: emailField.bottom + 15,
            width: view.width - 40,
            height: 55
        )
        signInButton.frame = CGRect(
            x: 20,
            y: passwordField.bottom + 20,
            width: view.width - 40,
            height: 55
        )
        forgotPassword.frame = CGRect(
            x: 20,
            y: signInButton.bottom + 40,
            width: view.width - 40,
            height: 55
        )
        signUpButton.frame = CGRect(
            x: 20,
            y: forgotPassword.bottom + 20,
            width: view.width - 40,
            height: 55
        )

    }

    // MARK: - Button actions

    @objc func didTapKeyboardDone() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }

    @objc func didTapSignIn() {
        didTapKeyboardDone()

        guard let email = emailField.text,
              let password = passwordField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else {

            let alert = UIAlertController(
                title: "Woops",
                message: "Please enter a valid email and password to sign in.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: "Dismiss",
                style: .cancel,
                handler: nil
            ))
            present(alert, animated: true)
            return

        }

        AuthManager.shared.signIn(with: email, password: password) { signInSuccess in
            if signInSuccess {
                // dismiss signin
            }
            else {
                // handle signin error
            }
        }

    }

    @objc func didTapSignUp() {
        didTapKeyboardDone()

        let vc = SignUpViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func didTapForgotPassword() {
        didTapKeyboardDone()

        guard let url = URL(string: "https://www.tiktok.com/forgot-password") else  {
            return
        }

        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
}
