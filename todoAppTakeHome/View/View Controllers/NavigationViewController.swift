//
//  NavigationViewController.swift
//  todoAppTakeHome
//
//  Created by John Kim on 11/6/20.
//

import UIKit

class NavigationViewController: UINavigationController{
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTransparentNavBar()
    }
}
