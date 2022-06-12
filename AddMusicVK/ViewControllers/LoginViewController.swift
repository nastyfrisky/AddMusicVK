//
//  WhiteViewController.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 21.05.2022.
//

import Foundation
import UIKit

final class LoginViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let loginButton = Button()
    private let imageView = UIImageView()
    private let logo = UIImage(named: "logoVK")
    private let inputField = TextInputField()
    private let textFieldViewModel = TextInputFieldViewModel(
        title: "Введите номер",
        subTitle: "Ваш номер телефона будет использоваться для входа в аккаунт",
        placeholder: "Email или телефон"
    )
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        
        addSubviews()
        setupButton()
        setupConstraints()
        inputField.configure(text: textFieldViewModel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Private Methods
    
    private func setupButton() {
        loginButton.setupButtons(title: "Продолжить") {
            guard let text = self.inputField.inputField.text, !text.isEmpty else {
                self.showAlert(title: "Ошибка", message: "Введите логин!")
                return
            }

            let login = UserLogin(login: text)
            let nextVC = PasswordViewController(login: login)
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    private func addSubviews() {
        imageView.image = logo
        view.addSubview(imageView)
        view.addSubview(inputField)
        view.addSubview(loginButton)
    }
    
    private func setupConstraints() {
        [imageView, inputField, loginButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
       
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: Constants.iconSize),
            imageView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            imageView.bottomAnchor.constraint(equalTo: inputField.topAnchor, constant: -Constants.borderSpacing)
        ])
        
        NSLayoutConstraint.activate([
            inputField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.borderSpacing),
            inputField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.borderSpacing),
            inputField.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -Constants.borderSpacing)
        ])
        
        NSLayoutConstraint.activate([
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.borderSpacing),
            loginButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Constants.borderSpacing
            ),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
}
