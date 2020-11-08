//
//  TaskCell.swift
//  todoAppTakeHome
//
//  Created by John Kim on 11/6/20.
//

import UIKit
import CoreData

class TaskCell: UITableViewCell {
    
    static let identifier = "TaskCell"
    
    //MARK:- UI Properties
    var checkBox = CheckBoxButton()
    var taskTitle = UILabel()
    var taskImage = UIImageView()
    
    //MARK:- Properties
    var currentTask : NSManagedObject?{
        didSet{
            let completed = currentTask?.value(forKey: "completed") as? Bool
            guard let complete = completed else {return}
            if(complete){
                checkBox.isChecked = true
            }else{
                checkBox.isChecked = false
            }
        }
    }

    //MARK:- Lifecycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        contentView.backgroundColor = .mainColor
        configureCheckbox()
        configureTitle()
    }
    
    //MARK:- UI Layout Configurations
    private func configureCheckbox(){
        contentView.addSubview(checkBox)
        
        checkBox.isUserInteractionEnabled = true
        checkBox.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)

        checkBox.translatesAutoresizingMaskIntoConstraints = false
        checkBox.widthAnchor.constraint(equalToConstant: 30).isActive = true
        checkBox.heightAnchor.constraint(equalToConstant: 30).isActive = true
        checkBox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 10).isActive = true
    }
    private func configureTitle(){
        contentView.addSubview(taskTitle)
        taskTitle.numberOfLines = 0
        taskTitle.font = .taskTitle
        taskTitle.textColor = .textColor

        taskTitle.translatesAutoresizingMaskIntoConstraints = false
        taskTitle.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        taskTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        taskTitle.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 30).isActive = true
        taskTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -10).isActive = true
    }


    //MARK:- User Interaction
    @objc func buttonClicked(sender: CheckBoxButton) {
        
        //fetching core data context here
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext

        let completed = currentTask?.value(forKey: "completed") as? Bool
        guard let complete = completed else {return}
        
        if(complete){
            do{
                currentTask?.setValue(false, forKey: "completed")
                try managedContext.save()
                sender.isChecked = !sender.isChecked
            }catch let error as NSError{
                print("Could not update checkbox")
            }
        }else{
            do{
                currentTask?.setValue(true, forKey: "completed")
                try managedContext.save()
                sender.isChecked = !sender.isChecked
   
            }catch let error as NSError{
                print("Could not update checkbox")
            }
        }
    }

}
