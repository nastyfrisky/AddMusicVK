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
    private let passwordButton = Button()
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
        captchaTextInput.action = captchaButtonTap
        
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
        activityIndicator.stopAnimating()
        setCaptchaInputVisibility(isHidden: false)
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
            setLoadingState(isEnabled: true)
        default:
            showAlert(title: "Ошибка", message: "Неизвестная ошибка")
            setLoadingState(isEnabled: true)
        }
    }
    
    func successSignIn() {
        let nextVC = UserIDViewController(vkService: vkService)
        navigationController?.pushViewController(nextVC, animated: true)
        setLoadingState(isEnabled: true)
    }
    
    func trackAddedSuccessfully() {}
    func trackAdditionError() {}
    func trackNumberUpdated(newNumber: Int) {}
    func tracksLoaded(tracksList: [Track], trackAddition: VkServiceAddTrackProtocol) {}
    func userPageLoadedSuccessfully() {}
    
    // MARK: - Private Methods
    
    private func setupButton() {
        passwordButton.setupButtons(title: "Продолжить") {
            self.buttonTap()
        }
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
    
    private func buttonTap() {
        guard let text = inputField.inputField.text, !text.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите пароль!")
            return
        }
        
        setLoadingState(isEnabled: false)
        vkService.delegate = self
        vkService.signIn(login: login.login, password: text)
    }
    
    private func captchaButtonTap() {
        guard let text = captchaTextInput.inputField.text, !text.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите текст с картинки!")
            return
        }
        
        setCaptchaInputVisibility(isHidden: true)
        callback?.enter(response: captchaTextInput.inputField.text ?? "")
    }
    
    private func setLoadingState(isEnabled: Bool) {
        passwordButton.isEnabled = isEnabled
        
        if isEnabled {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
    
    private func setCaptchaInputVisibility(isHidden: Bool) {
        captchaTextInput.isHidden = isHidden
        imageView.isHidden = !isHidden
        inputField.isHidden = !isHidden
        passwordButton.isHidden = !isHidden
    }
}
