//
//  TextInputField.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 21.05.2022.
//

import Foundation
import UIKit

final class TextInputField: UIView {
    let title = UILabel()
    let subTitle = UILabel()
    let inputField = CustomTextField()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        setupSubviews()
    }
    
    required init?(coder: NSCoder) { nil }
    
    func configure(text: TextInputFieldViewModel) {
        title.text = text.title
        subTitle.text = text.subTitle
        inputField.placeholder = text.placeholder
    }
    
    private func addSubviews() {
        addSubview(title)
        addSubview(subTitle)
        addSubview(inputField)
    }
    private func setupConstraints() {
        title.translatesAutoresizingMaskIntoConstraints = false
        subTitle.translatesAutoresizingMaskIntoConstraints = false
        inputField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor),
            title.leadingAnchor.constraint(equalTo: leadingAnchor),
            title.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            subTitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 15),
            subTitle.leadingAnchor.constraint(equalTo: leadingAnchor),
            subTitle.trailingAnchor.constraint(equalTo: trailingAnchor),
            subTitle.bottomAnchor.constraint(equalTo: inputField.topAnchor, constant: -15)
        ])

        NSLayoutConstraint.activate([
            inputField.leadingAnchor.constraint(equalTo: leadingAnchor),
            inputField.trailingAnchor.constraint(equalTo: trailingAnchor),
            inputField.bottomAnchor.constraint(equalTo: bottomAnchor),
            inputField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupSubviews() {
        title.textAlignment = .center
        title.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        
        subTitle.textAlignment = .center
        subTitle.numberOfLines = 0
        
        inputField.backgroundColor = .init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        inputField.layer.cornerRadius = 10
        inputField.clipsToBounds = true
    }
}
