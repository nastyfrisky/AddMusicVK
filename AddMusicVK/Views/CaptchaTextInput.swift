//
//  CaptchaTextInput.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 04.06.2022.
//

import Foundation
import UIKit

final class CaptchaTextInput: UIStackView {
    
    // MARK: - Public Properties
    
    var action = {}
    var captcha = UIImageView()
    let inputField = CustomTextField()
    let captchaButton = Button()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        setupStackView()
        setupSubviews()
        setupConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func addSubviews() {
        addArrangedSubview(captcha)
        addArrangedSubview(inputField)
        addArrangedSubview(captchaButton)
    }
    
    private func setupStackView() {
        axis = .vertical
        spacing = 15
    }
    
    private func setupSubviews() {
        captcha.contentMode = .scaleAspectFit
        
        inputField.backgroundColor = .init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        inputField.layer.cornerRadius = 10
        inputField.clipsToBounds = true
        inputField.placeholder = "Код с картинки"
        
        captchaButton.setupButtons(title: "Отправить") {
            self.action()
        }
    }
    
    private func setupConstraints() {
        [captcha, inputField, captchaButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            captcha.heightAnchor.constraint(equalToConstant: Constants.captchaHeight),
            inputField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            captchaButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
}
