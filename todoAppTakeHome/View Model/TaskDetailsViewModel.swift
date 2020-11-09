//
//  TaskDetailsViewModel.swift
//  todoAppTakeHome
//
//  Created by John Kim on 11/7/20.
//

import UIKit
import CoreData

class TaskDetailsViewModel{
    
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    func updateTitleEntry(_ task: NSManagedObject, _ entry: String){
        
        //fetching core data context here
        guard let appDelegate = appDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do{
            task.setValue(entry, forKey: "title")
            try managedContext.save()
            print("saved")
        }catch let error as NSError{
            print("Could not update checkbox")
        }
        
    }
    
    func deleteTask(_ task: NSManagedObject, completion: @escaping ((_ done: Bool) -> Void)){
        guard let appDelegate = appDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        managedContext.delete(task)
        do {
            try managedContext.save()
            completion(true)
            print("deleted")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func markComplete(_ task: NSManagedObject,_ complete: Bool){
        guard let appDelegate = appDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do{
            task.setValue(!complete, forKey: "completed")
            try managedContext.save()
            print("updated complete")
        }catch let error as NSError{
            print("Could not update ")
        }
    }
    
    func saveImage(_ task: NSManagedObject,_ data: Data) {
        guard let appDelegate = appDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            task.setValue(data, forKey: "image")

            try managedContext.save()
            print("Image is saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
