//
//  ViewController.swift
//  todoAppTakeHome
//
//  Created by John Kim on 11/6/20.
//

import UIKit
import CoreData

class HomePageViewController: UIViewController {
    
    //MARK:- UI Properties
    private var backgroundView = UIImageView()
    private var taskTitleLabel = UILabel()
    private var taskSearchBar = UISearchBar()
    private var taskTableView = UITableView()
    private var addTaskButton = UIButton()
    
    //MARK:- Properties
    override var preferredStatusBarStyle: UIStatusBarStyle {return .lightContent}
    private var localTasks : [NSManagedObject] = []{
        didSet{
            filteredTasks = localTasks
        }
    }
    private var filteredTasks : [NSManagedObject] = []
    private let viewModel = HomePageViewModel()
    
    
    //MARK:- Lifecycle Methods
    override func loadView() {
        super.loadView()
        
        setBackground(view, backgroundView)
        configureLabel()
        configSearchBar()
        configTableView()
        configNavBar()
        configureAddButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchTasks { [weak self] (result) in
            DispatchQueue.main.async {
                guard let self = self else {return}
                self.localTasks = result
                self.filteredTasks = self.localTasks
                self.taskTableView.reloadData()
            }
        }
        
    }
    
    //MARK:- UI Layout Configurations
    
    private func configNavBar(){
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = .navBarTint
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
    
    private func configSearchBar(){
        view.addSubview(taskSearchBar)
        taskSearchBar.backgroundColor = .mainColor
        taskSearchBar.barTintColor = .mainColor
        taskSearchBar.tintColor = .textColor

        taskSearchBar.delegate = self
        taskSearchBar.translatesAutoresizingMaskIntoConstraints = false
        taskSearchBar.topAnchor.constraint(equalTo: taskTitleLabel.bottomAnchor, constant: 15).isActive = true
        taskSearchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        taskSearchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    private func configTableView(){
        view.addSubview(taskTableView)
        taskTableView.backgroundColor = .mainColor
        taskTableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.identifier)
        taskTableView.delegate = self
        taskTableView.dataSource = self
        taskTableView.translatesAutoresizingMaskIntoConstraints = false
        taskTableView.topAnchor.constraint(equalTo: taskSearchBar.bottomAnchor).isActive = true
        taskTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        taskTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        taskTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func configureAddButton(){
        view.addSubview(addTaskButton)
        addTaskButton.setBackgroundImage(UIImage(named: "addButton"), for: .normal)
        addTaskButton.addTarget(self, action: #selector(addTask(sender:)), for: .touchUpInside)
        
        addTaskButton.translatesAutoresizingMaskIntoConstraints = false
        addTaskButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        addTaskButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        addTaskButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -view.frame.width*0.02).isActive = true
        addTaskButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -view.frame.height*0.02).isActive = true
        
    }
    //MARK:- Actions
    @objc func addTask(sender: UIButton){
  
        //Alert popup for textview input
        let ac = UIAlertController(title: "New Task", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Add", style: .default) { [unowned ac] _ in
            let field = ac.textFields![0]
            self.viewModel.addNewTask(field.text ?? "") { [weak self] (task) in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    self.localTasks.append(task)
                    self.taskTableView.reloadData()
                }
            }
            // do something interesting with "answer" here
        }

        ac.addAction(submitAction)

        present(ac, animated: true)
        
        //little bouncy animation
        UIView.animate(withDuration: 0.2,
            animations: {
                sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    sender.transform = CGAffineTransform.identity
                }
            })
    }
}
//MARK:- Tableview Delegate and Datasource
extension HomePageViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.identifier, for: indexPath) as! TaskCell
        let task = filteredTasks[indexPath.row]
        
        cell.taskTitle.text = task.value(forKey: "title") as? String
        cell.currentTask = task
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = TaskDetailsViewController()
        let task = filteredTasks[indexPath.row]
        
        vc.task = task
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    //setting cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(70.0)
    }
    //deleting tasks
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let task = filteredTasks[indexPath.row]
            filteredTasks.remove(at: indexPath.row)

            viewModel.deleteTask(task) { [weak self] (deleted) in
                guard let self = self else {return}
                if(deleted){
                    DispatchQueue.main.async {
                        self.taskTableView.reloadData()
                    }
                }
            }
            tableView.deleteRows(at: [indexPath], with: .fade)

        }
    }
    
}

//MARK:- Filtering Search Bar (Delegate)
extension HomePageViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText == "" || searchText == nil){
            DispatchQueue.main.async {
                self.filteredTasks = self.localTasks
                self.taskTableView.reloadData()
            }
        }else{
            self.filteredTasks = []
            let filter = searchText.lowercased()
                for task in localTasks{
                    let taskTitle = task.value(forKey: "title") as! String
                    if(taskTitle.contains(filter)){
                        filteredTasks.append(task)
                        }
                }
            
            DispatchQueue.main.async {
                self.taskTableView.reloadSections([0], with: .automatic)
            }
        }


    }
    //dismisses search bar keyboard
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        taskSearchBar.endEditing(true)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        taskSearchBar.endEditing(true)
    }
}

