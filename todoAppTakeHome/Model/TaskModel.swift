//
//  TaskModel.swift
//  todoAppTakeHome
//
//  Created by John Kim on 11/6/20.
//

import Foundation
//Decodable Model for JSON Serialization
struct TaskModel: Decodable{
    
    var userId: Int?
    var id: Int?
    var title: String?
    var completed: Bool?
    
}
