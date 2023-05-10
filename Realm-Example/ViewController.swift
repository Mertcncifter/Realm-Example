//
//  ViewController.swift
//  Realm-Example
//
//  Created by mert can çifter on 9.05.2023.
//

import UIKit
import RealmSwift
import JGProgressHUD

class ViewController: UIViewController {

    // MARK: - Properties
    
    private var viewModel : TodoViewModelProtocol! {
        didSet {
            viewModel.delegate = self
            viewModel.fetchTodos()
        }
    }
    
    private var todos = [Todo]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let spinner = JGProgressHUD(style: .dark)
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        viewModel = TodoViewModel()
        setupTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(didNewTodoButtonTapped))
        navigationItem.rightBarButtonItem = menuButton
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configureSpinner(state: Bool) {
        if state {
            spinner.show(in: view)
        }
        else {
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
        }
    }
    
    // MARK: - Selectors
    
    @objc private func didNewTodoButtonTapped() {
        let alertController = UIAlertController(title: "Add New Todo", message: "", preferredStyle: .alert)
       alertController.addTextField { (textField : UITextField!) -> Void in
           textField.placeholder = "Enter Todo Name"
       }
        
       let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
           let firstTextField = alertController.textFields![0] as UITextField
           
           guard let text = firstTextField.text else {
               return
           }
           self.viewModel.addTodo(name: text)
       })
       let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })

       alertController.addAction(saveAction)
       alertController.addAction(cancelAction)
       
       self.present(alertController, animated: true, completion: nil)
    }
        
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = todos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UITableViewCell
        cell.textLabel?.text = model.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let todo = todos[indexPath.row]
            
            tableView.beginUpdates()
            
            todos.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .left)
            
            tableView.endUpdates()
            
            
            viewModel.deleteTodo(with: todo)
        }
    }
    
}


// MARK: - TodoViewModelDelegate

extension ViewController: TodoViewModelDelegate {

    func handleViewModelOutput(_ output: TodoViewModelOutput) {
        switch output {
        case .setLoading(let bool):
            configureSpinner(state: bool)
        case .showTodos(let todos):
            self.todos = todos
        }
    }
}
