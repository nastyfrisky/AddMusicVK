//
//  VerificationViewController.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 23.05.2022.
//

import Foundation
import UIKit

final class VerificationViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let inputField = TextInputField()
    private let textFieldViewModel = TextInputFieldViewModel(
        title: "Подтвердите номер",
        subTitle: "Мы отправили SMS на номер",
        placeholder: "Код подтверждения"
    )
    private let verificationButton = UIButton()
    private let imageView = UIImageView()
    private let logo = UIImage(named: "logoVK")
    private let callback: VkServiceEnterRequestProtocol
    private let isErrorShowed: Bool
    
    // MARK: - Initializers
    
    init(callback: VkServiceEnterRequestProtocol, isErrorShowed: Bool) {
        self.callback = callback
        self.isErrorShowed = isErrorShowed
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isErrorShowed {
            showAlert(title: "Ошибка", message: "Неверный код!")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Private Methods
    
    private func setupButton() {
        verificationButton.backgroundColor = .init(red: 0.29, green: 0.45, blue: 0.65, alpha: 1)
        verificationButton.setTitle("Продолжить", for: .normal)
        verificationButton.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        
        verificationButton.layer.cornerRadius = 10
        verificationButton.clipsToBounds = true
    }
    
    private func addSubviews() {
        imageView.image = logo
        view.addSubview(imageView)
        view.addSubview(inputField)
        view.addSubview(verificationButton)
    }
    
    private func setupConstraints() {
        [imageView, inputField, verificationButton].forEach {
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
            inputField.bottomAnchor.constraint(equalTo: verificationButton.topAnchor, constant: -Constants.borderSpacing)
        ])
        
        NSLayoutConstraint.activate([
            verificationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.borderSpacing),
            verificationButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Constants.borderSpacing
            ),
            verificationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            verificationButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
    
    @objc private func buttonTap() {
        guard let text = inputField.inputField.text, !text.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите код!")
            return
        }

        callback.enter(response: text)
        dismiss(animated: true)
    }
}
