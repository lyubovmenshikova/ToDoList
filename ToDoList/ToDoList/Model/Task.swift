//
//  Task.swift
//  ToDoList
//
//  Created by Lyubov Menshikova on 20.03.2022.
//

import Foundation

protocol TaskProtocol {
    var title: String { get set }
    var type: TaskPriority { get set }
    var status: TaskStatus { get set }
}

struct Task: TaskProtocol {
    var title: String
    
    var type: TaskPriority
    
    var status: TaskStatus
}

enum TaskPriority {
    case important
    case normal
}

enum TaskStatus: Int {
    case planned
    case completed
}


protocol TaskListProtocol {
    var name: String { get set }
    var date: Date { get set }
    var tasks: [TaskProtocol] { get set }
}

struct TaskList: TaskListProtocol {
    var name: String
    var date: Date
    var tasks: [TaskProtocol]
}
