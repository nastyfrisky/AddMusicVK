//
//  UserIDViewController.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 23.05.2022.
//

import Foundation
import UIKit

final class UserIDViewController: UIViewController, VkServiceOutput {
    
    // MARK: - Private Properties
    
    private let inputField = TextInputField()
    private let textFieldViewModel = TextInputFieldViewModel(
        title: "Введите ID юзера",
        subTitle: "ID пользователя, музыку которого хотите добавить",
        placeholder: "id"
    )
    private let idButton = Button()
    private let imageView = UIImageView()
    private let logo = UIImage(named: "logoVK")
    private let vkService: VkService
    private lazy var activityIndicator = createSpinner(in: view)
    
    // MARK: - Initializers
    
    init(vkService: VkService) {
        self.vkService = vkService
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Public Methods
    
    func captchaRequested(image: UIImage, callback: VkServiceEnterRequestProtocol) {}
    func codeRequested(callback: VkServiceEnterRequestProtocol, isErrorShowed: Bool) {}
    func successSignIn() {}
    func trackAddedSuccessfully() {}
    func trackAdditionError() {}
    func trackNumberUpdated(newNumber: Int) {}
    func tracksLoaded(tracksList: [Track], trackAddition: VkServiceAddTrackProtocol) {}
    
    func userPageLoadedSuccessfully() {
        let nextVC = TrackListViewController(vkService: vkService)
        navigationController?.pushViewController(nextVC, animated: true)
        setLoadingState(isEnabled: true)
    }
    
    func processError(error: VkServiceProcessError) {
        switch error {
        case .wrongUserIdReceived, .notSignedIn:
            showAlert(title: "Ошибка", message: "Неверный ID!")
            setLoadingState(isEnabled: true)
        default:
            showAlert(title: "Ошибка", message: "Неизвестная ошибка!")
            setLoadingState(isEnabled: true)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupButton() {
        idButton.setupButtons(title: "Продолжить") {
            self.buttonTap()
        }
    }
    
    private func addSubviews() {
        imageView.image = logo
        view.addSubview(imageView)
        view.addSubview(inputField)
        view.addSubview(idButton)
    }
    
    private func setupConstraints() {
        [imageView, inputField, idButton].forEach {
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
            inputField.bottomAnchor.constraint(equalTo: idButton.topAnchor, constant: -Constants.borderSpacing)
        ])
        
        NSLayoutConstraint.activate([
            idButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.borderSpacing),
            idButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Constants.borderSpacing
            ),
            idButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            idButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
    
    private func buttonTap() {
        guard let text = inputField.inputField.text, !text.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите id пользователя!")
            return
        }
        
        setLoadingState(isEnabled: false)
        vkService.delegate = self
        vkService.startMusicProcess(profile: text)
    }
    
    private func setLoadingState(isEnabled: Bool) {
        idButton.isEnabled = isEnabled
        
        if isEnabled {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
}
