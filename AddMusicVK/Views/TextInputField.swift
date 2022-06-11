//
//  TextInputField.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 21.05.2022.
//

import Foundation
import UIKit

final class TextInputField: UIStackView {
    
    // MARK: - Public Properties
    
    let title = UILabel()
    let subTitle = UILabel()
    let inputField = CustomTextField()
   
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupStackView()
        setupSubviews()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(text: TextInputFieldViewModel) {
        title.text = text.title
        subTitle.text = text.subTitle
        inputField.placeholder = text.placeholder
        inputField.attributedPlaceholder = NSAttributedString(string: text.placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
    }
    
    // MARK: - Private Methods
    
    private func addSubviews() {
        addArrangedSubview(title)
        addArrangedSubview(subTitle)
        addArrangedSubview(inputField)
    }
    
    private func setupStackView() {
        axis = .vertical
        spacing = 15
    }
    
    private func setupSubviews() {
        title.textAlignment = .center
        title.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        title.textColor = .black
        
        subTitle.textAlignment = .center
        subTitle.numberOfLines = 0
        subTitle.textColor = .black
        
        inputField.backgroundColor = .init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        inputField.layer.cornerRadius = 10
        inputField.clipsToBounds = true
        inputField.textColor = .black
    }
}
