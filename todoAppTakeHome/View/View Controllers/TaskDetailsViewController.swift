//
//  TaskDetailsViewController.swift
//  todoAppTakeHome
//
//  Created by John Kim on 11/6/20.
//

import UIKit
import CoreData

class TaskDetailsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    //MARK:- UI Properties
    private var backgroundView = UIImageView()
    var taskImageView = UIImageView()
    var taskTitleLabel = UILabel()
    var taskTextView = UITextView()
    
    
    //MARK:- Properties
    let viewModel = TaskDetailsViewModel()
    var imagePicker = UIImagePickerController()
    var completeLabel = String()
    var task = NSManagedObject()
    
    //MARK:- Lifecycle Methods
    override func loadView() {
        super.loadView()
        
        setBackground(view, backgroundView)
        configureLabel()
        configureImageView()
        configureTextView()
        configureNavButtons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        settingProperties()
    }
    
    private func settingProperties(){
        taskTextView.text = task.value(forKey: "title") as? String
        let imgData = task.value(forKey: "image") as? Data
        guard let img = imgData else {return}
        taskImageView.image = UIImage(data: img)
    }
    //MARK:- UI Layout Configurations

    
    private func configureNavButtons(){
        let isComplete = task.value(forKey: "completed") as? Bool
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
    
    private func configureImageView(){
        view.addSubview(taskImageView)
        taskImageView.layer.cornerRadius = 15
        taskImageView.clipsToBounds = true
        taskImageView.contentMode = .scaleAspectFill
        taskImageView.backgroundColor = .textfieldColor	

        //set up tap gesture for imageview
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        taskImageView.isUserInteractionEnabled = true
        taskImageView.addGestureRecognizer(tapGestureRecognizer)

        taskImageView.translatesAutoresizingMaskIntoConstraints = false
        taskImageView.topAnchor.constraint(equalTo: taskTitleLabel.bottomAnchor, constant: view.frame.height * 0.02).isActive = true
        taskImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        taskImageView.widthAnchor.constraint(equalToConstant: view.frame.height * 0.1).isActive = true
        taskImageView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.1).isActive = true

    }
    
    private func configureTextView(){
        view.addSubview(taskTextView)
        taskTextView.backgroundColor = .textfieldColor
        taskTextView.font = .taskTextView
        taskTextView.textColor = .textColor
        taskTextView.layer.cornerRadius = 15
        taskTextView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        taskTextView.translatesAutoresizingMaskIntoConstraints = false
        taskTextView.topAnchor.constraint(equalTo: taskImageView.bottomAnchor, constant: view.frame.height * 0.02).isActive = true
        taskTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: view.frame.height * 0.02).isActive = true
        taskTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -view.frame.height * 0.02).isActive = true
        taskTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -view.frame.height * 0.1).isActive = true
    }

    //MARK:- Menu Actions
    
    //saves text to core data
    private func saveClicked() {
        viewModel.updateTitleEntry(task, taskTextView.text)
        navigationController?.popToRootViewController(animated: true)
    }
    //deletes obj from core data
    private func deleteClicked() {
        
        let alert = UIAlertController(title: "Delete?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Yes, delete", style: .destructive, handler: { action in
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")
            case .destructive:
                self.viewModel.deleteTask(self.task) { [weak self] (deleted) in
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
        var isComplete = task.value(forKey: "completed") as? Bool
        guard let complete = isComplete else {return}
        viewModel.markComplete(task, complete)
        if(complete){
            completeLabel = "Mark Incomplete"
        }else{
            completeLabel = "Mark Complete"
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //presenting image picker
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK:- UIImagePicker Delegates
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        //setting new image
        let data = image.pngData()
        guard let imgData = data else {return}
        viewModel.saveImage(task, imgData)
        taskImageView.image = image
    }
}
