//
//  TodoViewModel.swift
//  Realm-Example
//
//  Created by mert can çifter on 9.05.2023.
//

import Foundation
import RealmSwift


protocol TodoViewModelProtocol {
    var delegate: TodoViewModelDelegate? { get set }
    func fetchTodos()
    func addTodo(name: String)
    func deleteTodo(with todo: Todo)
}

enum TodoViewModelOutput{
    case setLoading(Bool)
    case showTodos([Todo])
}

protocol TodoViewModelDelegate: AnyObject {
    func handleViewModelOutput(_ output: TodoViewModelOutput)
}


final class TodoViewModel: TodoViewModelProtocol {
    
    let realmManager = RealmManager.shared

    weak var delegate: TodoViewModelDelegate?
    
    var notificationToken: NotificationToken?

    func fetchTodos() {
        let todos = realmManager.readAll(Todo.self)
        guard let todos = todos else {
            return
        }
        
        notify(.showTodos(Array(todos)))
        
        notificationToken = todos.observe { [weak self] change in
            switch change {
            case .initial:
                break
            case .update(let data, _, _, _):
                self?.notify(.showTodos(Array(data)))
                break
            case .error(let error):
                fatalError("\(error)")
            }
        }
        
    }
    
    func addTodo(name: String) {
        let todo = Todo()
        todo.name = name
        realmManager.create(todo)
    }
    
    func deleteTodo(with todo: Todo) {
        realmManager.delete(todo)
    }
    
    private func notify(_ output: TodoViewModelOutput){
        delegate?.handleViewModelOutput(output)
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
}
