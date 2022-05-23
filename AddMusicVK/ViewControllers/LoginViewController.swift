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
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100)
            
        ])
        
        NSLayoutConstraint.activate([
            inputField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inputField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            inputField.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func buttonTap() {
        let nextVC = PasswordViewController()
        navigationController?.pushViewController(nextVC, animated: true)
    }
}
