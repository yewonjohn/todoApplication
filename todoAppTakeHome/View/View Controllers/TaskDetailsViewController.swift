//
//  TaskDetailsViewController.swift
//  todoAppTakeHome
//
//  Created by John Kim on 11/6/20.
//

import UIKit
import CoreData

class TaskDetailsViewController: UIViewController{
    //MARK:- UI Properties
    var backgroundView = UIImageView()
    var taskTitleLabel = UILabel()
    var taskTextView = UITextView()
    
    
    //MARK:- Properties
    let viewModel = TaskDetailsViewModel()
    var completeLabel = String()
    var task : NSManagedObject?{
        didSet{
            taskTextView.text = task?.value(forKey: "title") as? String
        }
    }
    
    //MARK:- Lifecycle Methods
    override func loadView() {
        super.loadView()
        
        setBackground(view, backgroundView)
        configureLabel()
        configureTextView()
        configureNavButtons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    //MARK:- UI Layout Configurations
    
    private func configureNavButtons(){
        var isComplete = task?.value(forKey: "completed") as? Bool
        if(isComplete ?? false){
            completeLabel = "Mark Incomplete"
        }else{
            completeLabel = "Mark Complete"
        }
        
        let saveMenu = UIMenu(title: "", children: [
            UIAction(title: "Save", image: UIImage(named: "saveButton")) { action in
                self.saveClicked()
                },
             UIAction(title: "\(completeLabel)", image: UIImage(named: "pencil")) { action in
                self.completeClicked()
                },
             UIAction(title: "Delete", image: UIImage(named: "deleteButton")) { action in
                self.deleteClicked()
                },
              ])
        
        let navItem = UIBarButtonItem(image: UIImage(named: "menu"), menu: saveMenu)
        self.navigationItem.setRightBarButton(navItem, animated: true)

    }
    
    private func configureLabel(){
        view.addSubview(taskTitleLabel)
        taskTitleLabel.text = "TodoApp"
        taskTitleLabel.font = .taskTitleLabel
        taskTitleLabel.textColor = .textColor
        
        taskTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        taskTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        taskTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func configureTextView(){
        view.addSubview(taskTextView)
        taskTextView.backgroundColor = .mainColor
        taskTextView.font = .taskTextView
        taskTextView.textColor = .textColor
        taskTextView.layer.cornerRadius = 15
        taskTextView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        taskTextView.translatesAutoresizingMaskIntoConstraints = false
        taskTextView.topAnchor.constraint(equalTo: taskTitleLabel.bottomAnchor, constant: view.frame.height * 0.05).isActive = true
        taskTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        taskTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5).isActive = true
        taskTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -view.frame.height * 0.1).isActive = true
    }

    //MARK:- Menu Actions
    
    //saves text to core data
    private func saveClicked() {
        guard let task = task else {return}
        viewModel.updateTitleEntry(task, taskTextView.text)
        navigationController?.popToRootViewController(animated: true)
    }
    //deletes obj from core data
    private func deleteClicked() {
        guard let task = task else {return}
        
        let alert = UIAlertController(title: "Delete?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Yes, delete", style: .destructive, handler: { action in
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")
            case .destructive:
                self.viewModel.deleteTask(task) { [weak self] (deleted) in
                    guard let self = self else {return}
                    if(deleted == true){
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //updates complete to core data
    private func completeClicked(){
        var isComplete = task?.value(forKey: "completed") as? Bool
        guard let complete = isComplete else {return}
        guard let task = task else {return}
        viewModel.markComplete(task, complete)
        if(complete){
            completeLabel = "Mark Incomplete"
        }else{
            completeLabel = "Mark Complete"
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
}
