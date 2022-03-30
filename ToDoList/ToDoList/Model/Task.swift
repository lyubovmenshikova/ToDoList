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
    
    @Persisted var type = TaskPriority.important
    
    @Persisted var status = TaskStatus.planned
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
    @Persisted var name = ""
    @Persisted var date = Date()
    @Persisted var tasks: List<Task>
}
