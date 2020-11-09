//
//  CheckBoxUIButton.swift
//  todoAppTakeHome
//
//  Created by John Kim on 11/6/20.
//

import UIKit

class CheckBoxButton: UIButton {
    //MARK:- Properties
    private let checkedImage = UIImage(named: "checked")! as UIImage
    private let uncheckedImage = UIImage(named: "unchecked")! as UIImage
    
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setBackgroundImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setBackgroundImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }
}
