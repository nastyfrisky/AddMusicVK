//
//  VkServiceProcessSignIn.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 26.05.2022.
//

import WebKit

private enum VkServiceProcessStep {
    case preLoginInput
    case loginInput
    case passwordInput
    case codeInput
}

private enum VkServiceAdditionalData {
    case captcha
    case code
}

private enum VkServiceProcessState {
    case waitingPageEvent(step: VkServiceProcessStep)
    case waitingAdditionalData(type: VkServiceAdditionalData, nextStep: VkServiceProcessStep)
    case canceled
}

private enum VkServiceProcessPageEvents: String {
    case loginFormLoaded
    case passwordFormLoaded
    case codeFormLoaded
    case errorPresented
    case successSignedIn
    case captchaPresented
}

final class VkServiceProcessSignIn: NSObject, VkServiceProcessProtocol {
    
    // MARK: - Public Properties
    
    weak var delegate: VkServiceOutput?
    
    // MARK: - Private Properties
    
    private let signInUrl = "https://m.vk.com/join?vkid_auth_type=sign_in"
    private let observerName = "iOSObserver"
    private let parameterPattern = "FIELD_VALUE"
    private let stepPageEventsMap: [VkServiceProcessStep: [VkServiceProcessPageEvents]] = [
        .preLoginInput: [.loginFormLoaded],
        .loginInput: [.passwordFormLoaded, .errorPresented, .captchaPresented],
        .passwordInput: [.successSignedIn, .codeFormLoaded, .errorPresented, .captchaPresented],
        .codeInput: [.successSignedIn, .errorPresented, .captchaPresented]
    ]
    private var currentState: VkServiceProcessState = .waitingPageEvent(step: .preLoginInput)
    private weak var enterRequest: VkServiceEnterRequest?
    private let webView: WKWebView
    private let login: String
    private let password: String
    
    // MARK: - Initializers
    
    init(webView: WKWebView, login: String, password: String) {
        self.webView = webView
        self.login = login
        self.password = password
    }
    
    // MARK: - Public Methods
    
    func start() {
        guard let signInUrl = URL(string: signInUrl) else { return }
        let signInPageRequest = URLRequest(url: signInUrl)
        webView.navigationDelegate = self
        webView.load(signInPageRequest)
        webView.configuration.userContentController.add(self, name: observerName)
    }
    
    func cancel() {
        if case .canceled = currentState { return }
        currentState = .canceled
        
        webView.navigationDelegate = nil
        enterRequest?.delegate = nil
        webView.configuration.userContentController.removeScriptMessageHandler(forName: observerName)
    }
    
    // MARK: - Private Methods
    
    private func enterLogin() {
        currentState = .waitingPageEvent(step: .loginInput)
        webView.evaluateJavaScript(makeJsCode(with: login, and: VkServiceScripts.enterLogin))
    }
    
    private func enterPassword() {
        currentState = .waitingPageEvent(step: .passwordInput)
        webView.evaluateJavaScript(makeJsCode(with: password, and: VkServiceScripts.enterPassword))
    }
    
    private func enterCode(code: String) {
        webView.evaluateJavaScript(makeJsCode(with: code, and: VkServiceScripts.enterCode))
    }
    
    private func enterCaptcha(captcha: String) {
        webView.evaluateJavaScript(makeJsCode(with: captcha, and: VkServiceScripts.enterCaptcha))
    }
    
    private func handleCaptchaPresented(url: String?, currentStep: VkServiceProcessStep) {
        currentState = .waitingAdditionalData(type: .captcha, nextStep: currentStep)
        let request = VkServiceEnterRequest(delegate: self)
        enterRequest = request
        
        guard let url = url else { return }
        
        downloadImage(url: url) { [weak self] image in
            guard let image = image else {
                self?.handleProcessError(error: .captchaLoadingError)
                return
            }
        
            self?.delegate?.captchaRequested(image: image, callback: request)
        }
    }

    private func requestCode(isErrorShowed: Bool) {
        currentState = .waitingAdditionalData(type: .code, nextStep: .codeInput)
        let request = VkServiceEnterRequest(delegate: self)
        enterRequest = request
        delegate?.codeRequested(callback: request, isErrorShowed: isErrorShowed)
    }

    private func handleErrorPresented(currentStep: VkServiceProcessStep) {
        switch currentStep {
        case .loginInput:
            handleProcessError(error: .wrongLogin)
        case .passwordInput:
            handleProcessError(error: .wrongPassword)
        case .codeInput:
            requestCode(isErrorShowed: true)
        default:
            handleProcessError(error: .internalError)
        }
    }

    private func cancelIfNotCanceled() {
        if case .canceled = currentState { return }
        cancel()
    }
    
    private func handleProcessError(error: VkServiceProcessError) {
        cancelIfNotCanceled()
        delegate?.processError(error: error)
    }
    
    private func handleSuccessSignedIn() {
        cancelIfNotCanceled()
        delegate?.successSignIn()
    }
    
    private func makeJsCode(with parameter: String, and codePattern: String) -> String {
        let slashedParameter = parameter
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        return codePattern.replacingOccurrences(of: parameterPattern, with: slashedParameter)
    }
    
    private func downloadImage(url: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: url) else { return }
        
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            let cookiesString = cookies.map { "\($0.name)=\($0.value)" }.joined(separator: ";")
            
            var request = URLRequest(url: url)
            request.setValue(cookiesString, forHTTPHeaderField: "Cookie")
            request.httpShouldHandleCookies = true
            
            URLSession.shared.dataTask(with: request) { data, _, _ in
                guard let data = data, let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completion(image)
                }
            }.resume()
        }
    }
}

// MARK: - WKNavigationDelegate

extension VkServiceProcessSignIn: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript(VkServiceScripts.signInScript)
    }
}

// MARK: - WKScriptMessageHandler

extension VkServiceProcessSignIn: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let data = message.body as? [String : String] else { return }
        
        guard
            case let .waitingPageEvent(step) = currentState,
            let event = data["state"],
            let event = VkServiceProcessPageEvents(rawValue: event),
            let handlableEvants = stepPageEventsMap[step],
            handlableEvants.contains(event)
        else {
            handleProcessError(error: .unexpectedEvent)
            return
        }
        
        switch event {
        case .loginFormLoaded:
            enterLogin()
        case .passwordFormLoaded:
            enterPassword()
        case .codeFormLoaded:
            requestCode(isErrorShowed: false)
        case .errorPresented:
            handleErrorPresented(currentStep: step)
        case .captchaPresented:
            handleCaptchaPresented(url: data["captchaUrl"], currentStep: step)
        case .successSignedIn:
            handleSuccessSignedIn()
        }
    }
}

// MARK: - VkServiceEnterRequestDelegate

extension VkServiceProcessSignIn: VkServiceEnterRequestDelegate {
    func enter(response: String) {
        guard case let .waitingAdditionalData(type: dataType, nextStep: nextStep) = currentState else {
            handleProcessError(error: .unexpectedResponse)
            return
        }
        
        currentState = .waitingPageEvent(step: nextStep)
        
        switch dataType {
        case .code:
            enterCode(code: response)
        case .captcha:
            enterCaptcha(captcha: response)
        }
    }
}
