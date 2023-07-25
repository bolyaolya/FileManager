//
//  LoginViewController.swift
//  FileManager
//
//  Created by Ольга Бойко on 24.07.2023.
//

import Foundation
import UIKit
import KeychainAccess

fileprivate enum LoginData {
    static let enterPasswordText = "Введите ваш пароль"
    static let enterNewPasswordText = "Придумайте пароль (не менее 4-х символов)"
    static let confirmPasswordText = "Повторите ваш пароль"
    static let confirmNewPasswordText = "Повторите ваш новый пароль"
    static let signInText = "Войти"
    static let changePasswordText = "Изменить пароль"
}

final class LoginViewController: UIViewController {
    
    convenience init(isPasswordChangeState: Bool) {
        self.init()
        self.isPasswordChangeState = isPasswordChangeState
    }
    
    // MARK: - Properties
    
    private let keychain = Keychain(service: "FileManager")
    private var isFirstPasswordEntered = false
    
    private var isEnteredPasswordValid = false {
        didSet {
            loginButton.isEnabled = isEnteredPasswordValid
        }
    }
    private let passwordKey = "password_key"
    private var isKeychainEmpty = true {
        didSet {
            confirmPasswordTextField.isHidden = !isKeychainEmpty
            if !isKeychainEmpty {
                titleLabel.text = LoginData.enterPasswordText
            }
        }
    }
    private var isPasswordChangeState: Bool = false
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = LoginData.enterPasswordText
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = LoginData.enterPasswordText
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.textAlignment = .center
        textField.clearButtonMode = .whileEditing
        textField.layer.cornerRadius = 10.0
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = #colorLiteral(red: 0.03046085685, green: 0.03046085685, blue: 0.03046085685, alpha: 1)
        textField.isSecureTextEntry = true
        textField.clipsToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(passwordIsWriting), for: .editingChanged)
        return textField
    }()
    
    private lazy var confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = LoginData.confirmPasswordText
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.textAlignment = .center
        textField.clearButtonMode = .whileEditing
        textField.layer.cornerRadius = 10.0
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
        textField.isSecureTextEntry = true
        textField.clipsToBounds = true
        textField.addTarget(self, action: #selector(ConfirmationPasswordIsWriting), for: .editingChanged)
        textField.isEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(LoginData.signInText, for: .normal)
        button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        button.layer.cornerRadius = 10.0
        button.layer.borderWidth = 0.5
        button.layer.borderColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        setupConstraints()
        
        if isPasswordChangeState {
            titleLabel.text = LoginData.enterNewPasswordText
            passwordTextField.placeholder = LoginData.enterNewPasswordText
            confirmPasswordTextField.placeholder = LoginData.confirmNewPasswordText
            loginButton.setTitle(LoginData.changePasswordText, for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordTextField.text = nil
        if !isPasswordChangeState {
            guard let passwordFromKeychain = try? keychain.get(passwordKey),
                  !passwordFromKeychain.isEmpty else {
                isKeychainEmpty = true
                return
            }
            isKeychainEmpty = false
        } else {
            isKeychainEmpty = true
        }
        isEnteredPasswordValid = false
    }
    
    // MARK: - Methods
    
    private func addViews() {
        view.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        
        view.addSubview(titleLabel)
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(loginButton)
    }
    
    // MARK: - Actions
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            passwordTextField.widthAnchor.constraint(equalToConstant: 280),
            passwordTextField.heightAnchor.constraint(equalToConstant: 45),

            confirmPasswordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            confirmPasswordTextField.widthAnchor.constraint(equalToConstant: 280),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 45),

            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 40),
            loginButton.widthAnchor.constraint(equalToConstant: 280),
            loginButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    @objc private func passwordIsWriting() {
        if passwordTextField.text?.count ?? 0 >= 4 {
            if confirmPasswordTextField.isHidden {
                isEnteredPasswordValid = true
            } else {
                isEnteredPasswordValid = false
                confirmPasswordTextField.isEnabled = true
                titleLabel.text = isPasswordChangeState
                ? LoginData.confirmNewPasswordText
                : LoginData.confirmPasswordText
            }
        } else {
            isEnteredPasswordValid = false
            confirmPasswordTextField.isEnabled = false
            titleLabel.text = isPasswordChangeState
            ? LoginData.enterNewPasswordText
            : LoginData.enterPasswordText
        }
    }
    
    @objc private func ConfirmationPasswordIsWriting() {
        if passwordTextField.text == confirmPasswordTextField.text {
            isEnteredPasswordValid = true
        } else {
            isEnteredPasswordValid = false
        }
    }
    
    @objc private func loginButtonTapped() {
        guard let enteredPassword = passwordTextField.text else { return }
        if isKeychainEmpty {
            do {
                try keychain.set(enteredPassword, key: passwordKey)
                present(TabBarController(), animated: true)
            } catch (let error) {
                fatalError(error.localizedDescription)
            }
        } else {
            do {
                guard let savedPassword = try keychain.get(passwordKey) else { return }
                if savedPassword == enteredPassword {
                    present(TabBarController(), animated: true)
                } else {
                }
            } catch (let error) {
                fatalError(error.localizedDescription)
            }
        }
    }
}
