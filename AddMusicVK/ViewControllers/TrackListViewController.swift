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
    
    private let changeIDButton = UIButton()
    private let trackListButton = UIButton()
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
        activityIndicator.startAnimating()
        
        numberOfTracks.text = "Загружено \(newNumber) песен..."
    }
    
    func tracksLoaded(tracksList: [Track], trackAddition: VkServiceAddTrackProtocol) {
        activityIndicator.stopAnimating()
        
        numberOfTracks.isHidden = true
        
        changeIDButton.isEnabled = true
        trackListButton.isEnabled = true
        
        changeIDButton.backgroundColor = .init(red: 0.29, green: 0.45, blue: 0.65, alpha: 1.0)
        trackListButton.backgroundColor = .init(red: 0.29, green: 0.45, blue: 0.65, alpha: 1.0)
        
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
        trackListButton.setTitle("Начать перенос", for: .normal)
        changeIDButton.setTitle("Ввести другой ID", for: .normal)
        
        trackListButton.layer.cornerRadius = 10
        changeIDButton.layer.cornerRadius = 10
        
        trackListButton.clipsToBounds = true
        changeIDButton.clipsToBounds = true
        
        trackListButton.addTarget(self, action: #selector(getTracksButtonTap), for: .touchUpInside)
        changeIDButton.addTarget(self, action: #selector(changeIDButtonTap), for: .touchUpInside)
        
        trackListButton.isEnabled = false
        changeIDButton.isEnabled = false
        
        trackListButton.backgroundColor = .init(red: 0.29, green: 0.45, blue: 0.65, alpha: 0.5)
        changeIDButton.backgroundColor = .init(red: 0.29, green: 0.45, blue: 0.65, alpha: 0.5)
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
    
    @objc private func changeIDButtonTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func getTracksButtonTap() {
        trackListButton.isEnabled = false
        changeIDButton.isEnabled = false
        
        trackListButton.backgroundColor = .init(red: 0.29, green: 0.45, blue: 0.65, alpha: 0.5)
        changeIDButton.backgroundColor = .init(red: 0.29, green: 0.45, blue: 0.65, alpha: 0.5)
        
        activityIndicator.startAnimating()
        
        trackAddition?.addTrack(trackId: tracksInfo[trackNumber].trackId)
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
