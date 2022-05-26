//
//  TrackListViewController.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 23.05.2022.
//

import Foundation
import UIKit

final class TrackListViewController: UIViewController {
    let changeIDButton = UIButton()
    let trackListButton = UIButton()
    let trackList = UITableView()
    
    let singer = ["Николя Басков",
                  "Филипп Киркоров",
                  "Аллочка Пугачева",
                  "Леонид Агутин",
                  "Надежда Бабкина",
                  "Сергей Зверев"
    ]
    
    let track = ["Цвет настроения синий",
                 "Дольче габанна",
                 "А на море белый песок",
                 "Ласковая моя",
                 "Забудь его",
                 "Ветер с моря дул"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        trackList.register(UITableViewCell.self, forCellReuseIdentifier: "track")
        
        trackList.delegate = self
        trackList.dataSource = self
        
        addSubviews()
        setupConstraints()
        setupButtons()
    }
    
    private func setupButtons() {
        trackListButton.setTitle("Начать перенос", for: .normal)
        changeIDButton.setTitle("Ввести другой ID", for: .normal)
        
        changeIDButton.backgroundColor = .init(red: 0.29, green: 0.45, blue: 0.65, alpha: 1)
        trackListButton.backgroundColor = .init(red: 0.29, green: 0.45, blue: 0.65, alpha: 1)
        
        trackListButton.layer.cornerRadius = 10
        trackListButton.clipsToBounds = true
        
        changeIDButton.layer.cornerRadius = 10
        changeIDButton.clipsToBounds = true
    }
    
    private func addSubviews() {
        view.addSubview(changeIDButton)
        view.addSubview(trackListButton)
        view.addSubview(trackList)
    }
    
    private func setupConstraints() {
        changeIDButton.translatesAutoresizingMaskIntoConstraints = false
        trackListButton.translatesAutoresizingMaskIntoConstraints = false
        trackList.translatesAutoresizingMaskIntoConstraints = false
        
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
}

extension TrackListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        singer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let person = singer[indexPath.row]
        let track = track[indexPath.row]
        
        content.text = "\(person) - \(track)"
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    
}
