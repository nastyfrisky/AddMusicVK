//
//  RedViewController.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 21.05.2022.
//

import Foundation
import UIKit

final class PasswordViewController: UIViewController, VkServiceOutput {
    
    // MARK: - Private Properties
    
    private let inputField = TextInputField()
    private let captchaTextInput = CaptchaTextInput()
    private let textFieldViewModel = TextInputFieldViewModel(
        title: "Введите пароль",
        subTitle: "Используйте пароль, указанный при регистрации",
        placeholder: "Введите пароль"
    )
    private let vkService = VkService()
    private let passwordButton = UIButton()
    private let imageView = UIImageView()
    private let logo = UIImage(named: "logoVK")
    private let login: UserLogin
    private var callback: VkServiceEnterRequestProtocol?
    private lazy var activityIndicator = createSpinner(in: view)
    
    // MARK: - Initializers
    
    init(login: UserLogin) {
        self.login = login
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        vkService.webView.frame = view.frame
        
        imageView.contentMode = .scaleAspectFit
        
        inputField.inputField.isSecureTextEntry = true
        
        captchaTextInput.isHidden = true
        captchaTextInput.captchaButton.addTarget(self, action: #selector(captchaButtonTap), for: .touchUpInside)
        
        addSubviews()
        setupButton()
        setupConstraints()
        inputField.configure(text: textFieldViewModel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Public Methods
    
    func captchaRequested(image: UIImage, callback: VkServiceEnterRequestProtocol) {
        imageView.isHidden = true
        inputField.isHidden = true
        passwordButton.isHidden = true
        captchaTextInput.isHidden = false
        
        captchaTextInput.captcha.image = image
        
        self.callback = callback
    }
    
    func codeRequested(callback: VkServiceEnterRequestProtocol, isErrorShowed: Bool) {
        let nextVC = VerificationViewController(callback: callback, isErrorShowed: isErrorShowed)
        present(nextVC, animated: true)
    }
    
    func processError(error: VkServiceProcessError) {
        switch error {
        case .wrongLogin:
            showAlert(title: "Ошибка", message: "Некорректный логин") {
                self.navigationController?.popViewController(animated: true)
            }
        case .wrongPassword:
            showAlert(title: "Ошибка", message: "Неверный пароль")
            
            passwordButton.isEnabled = true
            passwordButton.backgroundColor = .init(red: 0.29, green: 0.45, blue: 0.65, alpha: 1.0)
            
            activityIndicator.stopAnimating()
        default:
            showAlert(title: "Ошибка", message: "Неизвестная ошибка")
            
            passwordButton.isEnabled = true
            passwordButton.backgroundColor = .init(red: 0.29, green: 0.45, blue: 0.65, alpha: 1.0)
            
            activityIndicator.stopAnimating()
        }
    }
    
    func successSignIn() {
        let nextVC = UserIDViewController(vkService: vkService)
        navigationController?.pushViewController(nextVC, animated: true)
        
        passwordButton.isEnabled = true
        passwordButton.backgroundColor = .init(red: 0.29, green: 0.45, blue: 0.65, alpha: 1.0)
        
        activityIndicator.stopAnimating()
    }
    
    func trackAddedSuccessfully() {}
    func trackAdditionError() {}
    func trackNumberUpdated(newNumber: Int) {}
    func tracksLoaded(tracksList: [Track], trackAddition: VkServiceAddTrackProtocol) {}
    func userPageLoadedSuccessfully() {}
    
    // MARK: - Private Methods
    
    private func setupButton() {
        passwordButton.backgroundColor = .init(red: 0.29, green: 0.45, blue: 0.65, alpha: 1)
        passwordButton.setTitle("Продолжить", for: .normal)
        passwordButton.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        
        passwordButton.layer.cornerRadius = 10
        passwordButton.clipsToBounds = true
    }
    
    private func addSubviews() {
        imageView.image = logo
        view.addSubview(imageView)
        view.addSubview(inputField)
        view.addSubview(passwordButton)
        view.addSubview(captchaTextInput)
    }
    
    private func setupConstraints() {
        [imageView, inputField, passwordButton, captchaTextInput].forEach {
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
            inputField.bottomAnchor.constraint(equalTo: passwordButton.topAnchor, constant: -Constants.borderSpacing)
        ])
        
        NSLayoutConstraint.activate([
            passwordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.borderSpacing),
            passwordButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Constants.borderSpacing
            ),
            passwordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            passwordButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
        
        NSLayoutConstraint.activate([
            captchaTextInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.borderSpacing),
            captchaTextInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.borderSpacing),
            captchaTextInput.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            
        ])
    }
    
    @objc private func buttonTap() {
        guard let text = inputField.inputField.text, !text.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите пароль!")
            return
        }
        
        passwordButton.isEnabled = false
        passwordButton.backgroundColor = .init(red: 0.29, green: 0.45, blue: 0.65, alpha: 0.5)
        
        activityIndicator.startAnimating()
        
        vkService.delegate = self
        vkService.signIn(login: login.login, password: text)
    }
    
    @objc private func captchaButtonTap() {
        guard let text = captchaTextInput.inputField.text, !text.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите текст с картинки!")
            return
        }
        
        captchaTextInput.isHidden = true
        imageView.isHidden = false
        inputField.isHidden = false
        passwordButton.isHidden = false
        
        callback?.enter(response: captchaTextInput.inputField.text ?? "")
       
    }
}
