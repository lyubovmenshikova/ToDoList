//
//  StorageManager.swift
//  ToDoList
//
//  Created by Lyubov Menshikova on 28.03.2022.
//

import Foundation
import RealmSwift

class StorageManager {
    
    static let shared = StorageManager()
    
    let realm = try! Realm()
    
    private init() {}
    
 
    // MARK: методы сохранения
    func save(taskList: TaskList) {
        write {
            realm.add(taskList)
        }
    }
    
    func save(task: Task, in taskList: TaskList) {
        write {
            taskList.tasks.append(task)
        }
    }
    
    private func write(_ completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch let error {
            print(error)
        }
    }
    
    //MARK: методы редактирования
    func edit(taskList: TaskList, newValue: String) {
        write {
            taskList.name = newValue
        }
    }
    
    func edit(task: Task, name: String) {
        write {
            task.title = name
        }
    }
    
    //MARK: методы удаления
    func delete(taskList: TaskList) {
        write {
            let tasks = taskList.tasks
            realm.delete(tasks)
            realm.delete(taskList)
        }
    }
   
    func delete(task: Task) {
        write {
            realm.delete(task)
        }
    }
    
}
