//
//  Button.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 11.06.2022.
//

import Foundation
import UIKit

final class Button: UIButton {
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                backgroundColor = .init(red: 0.29, green: 0.45, blue: 0.65, alpha: 1.0)
            } else {
                backgroundColor = .init(red: 0.29, green: 0.45, blue: 0.65, alpha: 0.5)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupButtons(title: String, action: () -> Void) {
        setTitle(title, for: .normal)
        layer.cornerRadius = 10
        clipsToBounds = true
        
    }
    
    @objc private func buttonTap(action: () -> Void) {}
}
