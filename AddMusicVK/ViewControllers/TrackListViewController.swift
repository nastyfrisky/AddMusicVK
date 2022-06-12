//
//  TrackListViewController.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 23.05.2022.
//

import Foundation
import UIKit

final class TrackListViewController: UIViewController, VkServiceOutput {
    
    // MARK: - Private Properties
    
    private let changeIDButton = Button()
    private let trackListButton = Button()
    private let trackList = UITableView()
    private let numberOfTracks = UILabel()
    private let vkService: VkService
    private var trackAddition: VkServiceAddTrackProtocol?
    private var tracksInfo: [Track] = []
    private var trackNumber: Int = 0
    private lazy var activityIndicator = createSpinner(in: view)
    
    // MARK: - Initializers
    
    init(vkService: VkService) {
        self.vkService = vkService
        super.init(nibName: nil, bundle: nil)
        vkService.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        numberOfTracks.textColor = .black
        
        addSubviews()
        setupConstraints()
        setupButtons()
        setupTrackList()
        
        vkService.webView.isHidden = true
    }
    
    // MARK: - Public Methods
    
    func captchaRequested(image: UIImage, callback: VkServiceEnterRequestProtocol) {}
    func codeRequested(callback: VkServiceEnterRequestProtocol, isErrorShowed: Bool) {}
    func successSignIn() {}
    func userPageLoadedSuccessfully() {}
    
    func processError(error: VkServiceProcessError) {
        switch error {
        case .wrongTrackList:
            showAlert(title: "Ошибка", message: "Не удалось загрузить треки. Попробуйте снова.") {
                self.navigationController?.popViewController(animated: true)
            }
        default:
            showAlert(title: "Ошибка", message: "Неизвестная ошибка!") {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func trackAddedSuccessfully() {
        addTrack()
    }
    
    func trackAdditionError() {
        addTrack()
    }
    
    func trackNumberUpdated(newNumber: Int) {
        numberOfTracks.text = "Загружено \(newNumber) песен..."
    }
    
    func tracksLoaded(tracksList: [Track], trackAddition: VkServiceAddTrackProtocol) {
        numberOfTracks.isHidden = true
        setLoadingState(isEnabled: true)
        tracksInfo = tracksList
        self.trackAddition = trackAddition
        trackList.reloadData()
    }
    
    // MARK: - Private Methods
    
    private func addTrack() {
        if trackNumber < tracksInfo.count - 1 {
            trackNumber = trackNumber + 1
            trackAddition?.addTrack(trackId: tracksInfo[trackNumber].trackId)
        } else {
            showAlert(title: "Готово", message: "Музыка успешно добавлена!") {
                self.navigationController?.pushViewController(LoginViewController(), animated: true)
            }
        }
    }
    
    private func setupButtons() {
        setLoadingState(isEnabled: false)
        
        trackListButton.setupButtons(title: "Начать перенос") {
            self.getTracksButtonTap()
        }
        
        changeIDButton.setupButtons(title: "Ввести другой ID") {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func addSubviews() {
        view.addSubview(changeIDButton)
        view.addSubview(trackListButton)
        view.addSubview(trackList)
        view.addSubview(vkService.webView)
        view.addSubview(numberOfTracks)
    }
    
    private func setupTrackList() {
        trackList.register(UITableViewCell.self, forCellReuseIdentifier: "track")
        trackList.dataSource = self
        trackList.backgroundColor = .white
    }
    
    private func setupConstraints() {
        [changeIDButton, trackListButton, trackList, numberOfTracks].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            numberOfTracks.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            numberOfTracks.bottomAnchor.constraint(equalTo: activityIndicator.topAnchor, constant: -Constants.borderSpacing)
        ])
        
        NSLayoutConstraint.activate([
            trackList.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackList.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackList.bottomAnchor.constraint(equalTo: changeIDButton.topAnchor, constant: -Constants.borderSpacing)
        ])
        
        NSLayoutConstraint.activate([
            changeIDButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.borderSpacing),
            changeIDButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.borderSpacing),
            changeIDButton.bottomAnchor.constraint(equalTo: trackListButton.topAnchor, constant: -Constants.borderSpacing),
            changeIDButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
        
        NSLayoutConstraint.activate([
            trackListButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.borderSpacing),
            trackListButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.borderSpacing),
            trackListButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.borderSpacing),
            trackListButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
    
    private func getTracksButtonTap() {
        setLoadingState(isEnabled: false)
        trackAddition?.addTrack(trackId: tracksInfo[trackNumber].trackId)
    }
    
    private func setLoadingState(isEnabled: Bool) {
        trackListButton.isEnabled = isEnabled
        changeIDButton.isEnabled = isEnabled
        
        if isEnabled {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
}

// MARK: - UITableViewDataSource

extension TrackListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tracksInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let person = tracksInfo[indexPath.row].artist
        let track = tracksInfo[indexPath.row].name
        
        content.text = "\(person) - \(track)"
        content.textProperties.color = .black
        
        cell.contentConfiguration = content
        cell.backgroundColor = .white
        cell.contentView.backgroundColor = .white
        
        return cell
    }
}
