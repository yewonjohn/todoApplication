//
//  UserDefaultUtil.swift
//  todoAppTakeHome
//
//  Created by John Kim on 11/8/20.
//

import Foundation

class UserDefaultUtil{
    
    static var firstTimeRun : Bool{
        get{
            UserDefaults.standard.bool(forKey: "firstTimeRun")
        }
        
        set{
            UserDefaults.standard.setValue(newValue, forKey: "firstTimeRun")

        }
    }
    
}
