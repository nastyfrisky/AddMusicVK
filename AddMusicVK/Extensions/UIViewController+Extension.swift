//
//  UIViewController+Extension.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 24.05.2022.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(error: String) {
        let alertController = UIAlertController(
            title: "Ошибка",
            message: error,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
