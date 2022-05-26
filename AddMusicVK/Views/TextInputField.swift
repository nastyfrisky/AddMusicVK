//
//  TextInputField.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 21.05.2022.
//

import Foundation
import UIKit

final class TextInputField: UIStackView {
    let title = UILabel()
    let subTitle = UILabel()
    let inputField = CustomTextField()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupStackView()
        setupSubviews()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: TextInputFieldViewModel) {
        title.text = text.title
        subTitle.text = text.subTitle
        inputField.placeholder = text.placeholder
    }
    
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
        
        subTitle.textAlignment = .center
        subTitle.numberOfLines = 0
        
        inputField.backgroundColor = .init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        inputField.layer.cornerRadius = 10
        inputField.clipsToBounds = true
    }
}
