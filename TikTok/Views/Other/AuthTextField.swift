//
//  AuthTextField.swift
//  TikTok
//
//  Created by 206568245 on 11/6/23.
//

import UIKit

class AuthTextField: UITextField {

    enum FieldType {
        case username
        case email
        case password

        var title: String {
            switch self {
            case .username: return "Username"
            case .email : return "Email Address"
            case .password: return "Password"
            }
        }
    }

    private let type: FieldType

    // MARK: - Init

    init(type: FieldType) {
        self.type = type
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        if type == .password {
            isSecureTextEntry = true
        }

        if type == .email {
            keyboardType = .emailAddress
        }

        returnKeyType = .done
        autocorrectionType = .no
        autocapitalizationType = .none
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
        layer.masksToBounds = true
        placeholder = type.title

        leftView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: 10,
            height: height
        ))
        leftViewMode = .always
    }
}
