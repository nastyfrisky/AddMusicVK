//
//  WhiteViewController.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 21.05.2022.
//

import Foundation
import UIKit

final class LoginViewController: UIViewController {
    let inputField = TextInputField()
    let textFieldViewModel = TextInputFieldViewModel(
        title: "Введите номер",
        subTitle: "Ваш номер телефона будет использоваться для входа в аккаунт",
        placeholder: "Email или телефон"
    )
    let loginButton = UIButton()
    let imageView = UIImageView()
    let logo = UIImage(named: "logoVK")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        imageView.contentMode = .scaleAspectFit
        
        loginButton.backgroundColor = .init(red: 0.29, green: 0.45, blue: 0.65, alpha: 1)
        loginButton.setTitle("Продолжить", for: .normal)
        loginButton.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        
        loginButton.layer.cornerRadius = 10
        loginButton.clipsToBounds = true
        
        addSubviews()
        setupConstraints()
        inputField.configure(text: textFieldViewModel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    private func addSubviews() {
        imageView.image = logo
        view.addSubview(imageView)
        view.addSubview(inputField)
        view.addSubview(loginButton)
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        inputField.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    @objc private func buttonTap() {
        guard let text = inputField.inputField.text, !text.isEmpty else {
            showAlert(error: "Введите логин!")
            return
        }
        
        let login = UserLogin(login: text)
        let nextVC = PasswordViewController(login: login)
        
        navigationController?.pushViewController(nextVC, animated: true)
    }
}
