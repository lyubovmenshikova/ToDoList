//
//  AlertController.swift
//  ToDoList
//
//  Created by Lyubov Menshikova on 25.03.2022.
//

import UIKit

//class AlertController: UIAlertController {
//
//    var doneButton = "Сохранить"
//    
//    //функция редактирования  или добавления списка задач
//    func editAction(with taskList: TaskListProtocol?, completion: @escaping (String) -> Void) {
//        
//        if taskList != nil {
//            doneButton = "Перезаписать"
//        }
//        
//        let saveAction = UIAlertAction(title: doneButton,
//                                       style: .default) { _ in
//            guard let newValue = self.textFields?.first?.text else { return }
//            guard !newValue.isEmpty else { return }
//            completion(newValue)
//        }
//        
//        let cancelAction = UIAlertAction(title: "Отменить", style: .destructive, handler: nil)
//        
//        addAction(saveAction)
//        addAction(cancelAction)
//        addTextField { textField in
//            textField.placeholder = "Введите название списка"
//            textField.text = taskList?.name
//        }
//    }
//    
//}
