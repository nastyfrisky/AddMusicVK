//
//  customTextField.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 22.05.2022.
//

import Foundation
import UIKit

final class CustomTextField: UITextField {
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addTarget(self, action: #selector(editingBegan), for: .editingDidBegin)
        
        layer.borderColor = CGColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        layer.borderWidth = 1
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Override Methods
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 10, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 10, dy: 0)
    }
    
    // MARK: - Private Methods
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Constants.textFieldHeight)
        ])
    }
    
    @objc private func editingBegan() {
        layer.borderColor = CGColor(red: 0.29, green: 0.45, blue: 0.65, alpha: 1)
    }
}
