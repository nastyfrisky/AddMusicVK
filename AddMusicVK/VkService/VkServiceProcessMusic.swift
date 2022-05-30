//
//  VkServiceProcessMusic.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 28.05.2022.
//

import WebKit

private enum VkServiceProcessStep {
    case userIdReceiving
    case trackListLoading
    case trackAdding
}

private enum VkServiceProcessState {
    case waitingPageEvent(step: VkServiceProcessStep)
    case waitingTrackAdditionRequest
    case canceled
}

private enum VkServiceProcessPageEvents: String {
    case notSignedIn
    case profilePageLoaded
    case musicPageLoaded
    case allMusicLoaded
    case moreTracksLoading
    case trackNotFound
    case addTrackButtonNotFound
    case cancelElementNotFound
    case trackAddedSuccessfully
}

struct Track {
    let name: String
    let artist: String
    let trackId: String
}

protocol VkServiceAddTrackProtocol: AnyObject {
    func addTrack(trackId: String)
}

final class VkServiceProcessMusic: NSObject, VkServiceProcessProtocol {
    
    // MARK: - Public Properties
    
    var delegate: VkServiceOutput?
    
    // MARK: - Private Properties
    
    private let pageUrl = "https://m.vk.com/"
    private let observerName = "iOSObserver"
    private let stepPageEventsMap: [VkServiceProcessStep: [VkServiceProcessPageEvents]] = [
        .userIdReceiving: [.profilePageLoaded, .notSignedIn],
        .trackListLoading: [.musicPageLoaded, .moreTracksLoading, .allMusicLoaded],
        .trackAdding: [.trackAddedSuccessfully]
    ]
    private var currentState: VkServiceProcessState = .waitingPageEvent(step: .userIdReceiving)
    private let webView: WKWebView
    private let profile: String
    
    // MARK: - Initializers
    
    init(webView: WKWebView, profile: String) {
        self.webView = webView
        self.profile = profile
    }
    
    // MARK: - Public Methods
    
    func start() {
        guard let pageUrl = URL(string: "\(pageUrl)\(profile)") else { return }
        let profilePageRequest = URLRequest(url: pageUrl)
        webView.navigationDelegate = self
        webView.load(profilePageRequest)
        webView.configuration.userContentController.add(self, name: observerName)
    }
    
    func cancel() {
        if case .canceled = currentState { return }
        currentState = .canceled
        
        webView.navigationDelegate = nil
        webView.configuration.userContentController.removeScriptMessageHandler(forName: observerName)
    }
    
    // MARK: - Private Methods
    
    private func handleProfilePageLoaded(userId: String?) {
        guard let userId = userId else {
            handleProcessError(error: .wrongUserIdReceived)
            return
        }
        
        currentState = .waitingPageEvent(step: .trackListLoading)
        
        delegate?.userPageLoadedSuccessfully()
        
        guard let musicUrl = URL(string: "\(pageUrl)audios\(userId)") else { return }
        let musicPageRequest = URLRequest(url: musicUrl)
        webView.load(musicPageRequest)
    }
    
    private func handleAllMusicLoaded(tracksList: [[String: String]]?) {
        guard let tracksList = tracksList else {
            handleProcessError(error: .wrongTrackList)
            return
        }
        
        let trackListModels: [Track] = tracksList.compactMap { trackData in
            guard
                let name = trackData["name"],
                let artist = trackData["artist"],
                let trackId = trackData["id"]
            else { return nil }
            return Track(name: name, artist: artist, trackId: trackId)
        }
        
        currentState = .waitingTrackAdditionRequest
        delegate?.tracksLoaded(tracksList: trackListModels, trackAddition: self)
    }
    
    private func cancelIfNotCanceled() {
        if case .canceled = currentState { return }
        cancel()
    }
    
    private func handleProcessError(error: VkServiceProcessError) {
        cancelIfNotCanceled()
        delegate?.processError(error: error)
    }
}

// MARK: - WKNavigationDelegate

extension VkServiceProcessMusic: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript(VkServiceScripts.musicScript)
    }
}

// MARK: - WKScriptMessageHandler

extension VkServiceProcessMusic: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let data = message.body as? [String: Any] else { return }
        
        guard
            case let .waitingPageEvent(step) = currentState,
            let event = data["state"] as? String,
            let event = VkServiceProcessPageEvents(rawValue: event),
            let handlableEvents = stepPageEventsMap[step],
            handlableEvents.contains(event)
        else {
            handleProcessError(error: .unexpectedEvent)
            return
        }
        
        switch event {
        case .notSignedIn:
            handleProcessError(error: .notSignedIn)
        case .profilePageLoaded:
            handleProfilePageLoaded(userId: data["userID"] as? String)
        case .musicPageLoaded:
            break
        case .allMusicLoaded:
            handleAllMusicLoaded(tracksList: data["tracksList"] as? [[String: String]])
        case .moreTracksLoading:
            delegate?.trackNumberUpdated(newNumber: data["tracksNumber"] as? Int ?? 0)
        case .trackAddedSuccessfully:
            currentState = .waitingTrackAdditionRequest
            delegate?.trackAddedSuccessfully()
        default:
            handleProcessError(error: .internalError)
        }
    }
}

// MARK: - VkServiceAddTrackProtocol

extension VkServiceProcessMusic: VkServiceAddTrackProtocol {
    func addTrack(trackId: String) {
        guard case .waitingTrackAdditionRequest = currentState else {
            delegate?.trackAdditionError()
            return
        }
        
        let slashedParameter = trackId
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        
        currentState = .waitingPageEvent(step: .trackAdding)
        webView.evaluateJavaScript("commandAddTrack(\"\(slashedParameter)\");")
    }
}
