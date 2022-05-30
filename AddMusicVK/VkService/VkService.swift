//
//  VkService.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 24.05.2022.
//

import WebKit

enum VkServiceProcessError {
    case captchaLoadingError
    case internalError
    case unexpectedEvent
    case unexpectedResponse
    case wrongLogin
    case wrongPassword
    case notSignedIn
    case wrongUserIdReceived
    case wrongTrackList
}

protocol VkServiceOutput: AnyObject {
    func captchaRequested(image: UIImage, callback: VkServiceEnterRequestProtocol)
    func codeRequested(callback: VkServiceEnterRequestProtocol, isErrorShowed: Bool)
    func processError(error: VkServiceProcessError)
    func successSignIn()
    
    func userPageLoadedSuccessfully()
    func trackAddedSuccessfully()
    func trackAdditionError()
    func trackNumberUpdated(newNumber: Int)
    func tracksLoaded(tracksList: [Track], trackAddition: VkServiceAddTrackProtocol)
}

final class VkService {
    
    // MARK: - Public Properties
    
    weak var delegate: VkServiceOutput? {
        didSet {
            currentProcess?.delegate = delegate
        }
    }
    
    let webView: WKWebView
    
    // MARK: - Private Properties
    
    private var currentProcess: VkServiceProcessProtocol?
    
    // MARK: - Initializers
    
    init() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        webView = WKWebView(frame: .zero, configuration: configuration)
    }
    
    // MARK: - Public Methods
    
    func signIn(login: String, password: String) {
        currentProcess?.cancel()
        let process = VkServiceProcessSignIn(webView: webView, login: login, password: password)
        process.delegate = delegate
        currentProcess = process
        process.start()
    }
    
    func startMusicProcess(profile: String) {
        currentProcess?.cancel()
        let process = VkServiceProcessMusic(webView: webView, profile: profile)
        process.delegate = delegate
        currentProcess = process
        process.start()
    }
}
