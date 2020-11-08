//
//  HomePageViewModel.swift
//  todoAppTakeHome
//
//  Created by John Kim on 11/6/20.
//

import UIKit
import CoreData

class HomePageViewModel {
    
    //MARK:- Properties
    private let userDefault = UserDefaults.standard
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate

    func getTasks(completion: @escaping ((_ tasks: [TaskModel]) -> Void)){
        
        let session = URLSession.shared
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/")!
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            // Check the response
            print(response)
            // Check if an error occured
            if error != nil {
                // Here you can manage the error
                print(error)
                return
            }
            // Serialize the data into an object
            do {
                let resultTasks = try JSONDecoder().decode([TaskModel].self, from: data!)
                //try JSONSerialization.jsonObject(with: data!, options: [])
                
                completion(resultTasks)
            } catch {
                print("Error during JSON serialization: \(error.localizedDescription)")
            }
            
        })
        task.resume()
        
    }
    //MARK:- Core Data Methods
    func fetchTasks(completion: @escaping ((_ finished: [NSManagedObject]) -> Void)){
        
        //fetch from API if first time running
        var taskModels = [TaskModel]()
        let operationQueue = OperationQueue()
        //checks if running first time
        if !userDefault.bool(forKey: "firstTimeRun"){
            //setting up first task (API Call)
            let getTasksNetwork = BlockOperation {
                let dispatchGroup1 = DispatchGroup()
                dispatchGroup1.enter()
                
                self.getTasks { (tasks) in
                    taskModels = tasks
                    dispatchGroup1.leave()
                }
                dispatchGroup1.wait()
            }
            //setting up second task (Saving to Core Data)
            let saveTasksLocally = BlockOperation{
                let dispatchGroup2 = DispatchGroup()
                dispatchGroup2.enter()
                
                self.saveToCoreData(listOfTasks: taskModels) { (result) in
                    completion(result)
                    self.userDefault.set(true, forKey: "firstTimeRun")
                    self.userDefault.synchronize()
                    dispatchGroup2.leave()
                }
                dispatchGroup2.wait()
            }
            
            saveTasksLocally.addDependency(getTasksNetwork)
            operationQueue.addOperation(getTasksNetwork)
            operationQueue.addOperation(saveTasksLocally)
            
        //If not first time, fetch data locally
        }else{
            fetchTasksLocal(){ (result) in
                completion(result)
            }
        }
    }
    
    private func fetchTasksLocal(completion: @escaping ((_ finished: [NSManagedObject]) -> Void)){
        var resultTasks = [NSManagedObject]()
        guard let appDelegate = appDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        
        do {
            resultTasks = try managedContext.fetch(fetchRequest)
            completion(resultTasks)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    private func saveToCoreData(listOfTasks: [TaskModel], completion: @escaping ((_ finished: [NSManagedObject]) -> Void)) {
        var resultTasks = [NSManagedObject]()
        
        guard let appDelegate = appDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext) else { return }
        //need to call .perform so this block runs on main thread
        print(Thread.current)
        managedContext.perform {
            print(Thread.current)

            for task in listOfTasks{
                let localTask = NSManagedObject(entity: entity, insertInto: managedContext)
                
                localTask.setValue(task.title, forKeyPath: "title")
                localTask.setValue(task.id, forKeyPath: "id")
                localTask.setValue(task.userId, forKeyPath: "userId")
                localTask.setValue(task.completed, forKeyPath: "completed")
                
                do {
                    try managedContext.save()
                    resultTasks.append(localTask)
                    if(resultTasks.count == listOfTasks.count){
                        completion(resultTasks)
                    }
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
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
    
    func addNewTask(_ taskEntry: String, completion: @escaping ((_ task: NSManagedObject) -> Void)){
        guard let appDelegate = appDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext) else { return }
        let localTask = NSManagedObject(entity: entity, insertInto: managedContext)
        
        localTask.setValue(taskEntry, forKeyPath: "title")
        //putting random id values for these.. didn't have time to setup user/id unique identifier progressions
        localTask.setValue(Int.random(in: 0...999), forKeyPath: "id")
        localTask.setValue(Int.random(in: 0...999), forKeyPath: "userId")
        localTask.setValue(false, forKeyPath: "completed")
        
        do {
            try managedContext.save()
            completion(localTask)
            print("New Task Saved")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
}







