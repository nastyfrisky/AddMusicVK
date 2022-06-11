//
//  ViewController.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 21.05.2022.
//

import UIKit

class NavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        pushViewController(LoginViewController(), animated: false)
    }
}

