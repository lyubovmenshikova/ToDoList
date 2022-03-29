//
//  Task.swift
//  ToDoList
//
//  Created by Lyubov Menshikova on 20.03.2022.
//

import Foundation
import RealmSwift


class Task: Object {
    @Persisted var title: String = ""
    
    @objc dynamic var type = TaskPriority.important.rawValue
    var priorityEnum: TaskPriority {
        get { return TaskPriority(rawValue: type)! }
        set { type = newValue.rawValue }
    }
    
    @objc dynamic var status = TaskStatus.planned.rawValue
    var statusEnum: TaskStatus {
        get { return TaskStatus(rawValue: status)! }
        set { status = newValue.rawValue }
    }
}

enum TaskPriority: String, PersistableEnum {
    case important
    case normal
}

enum TaskStatus: String, PersistableEnum {
    case planned
    case completed
}


class TaskList: Object {
    @objc dynamic var name = ""
    @objc dynamic var date = Date()
    let tasks = List<Task>()
}
