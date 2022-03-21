//
//  TaskTypeController.swift
//  ToDoList
//
//  Created by Lyubov Menshikova on 21.03.2022.
//

import UIKit

class TaskTypeController: UITableViewController {
    
    //кортеж описывающий тип задачи
    typealias TypeCellDescription = (type: TaskPriority, title: String, description: String)
    
    // коллекция доступных типов задач с их описанием
    private var taskTypeInformation: [TypeCellDescription] = [
        (type: .important, title: "Важная", description: "Тип задач - наиболее приоритетный для выполнения. Все важные задачи выводятся в самом верху списка задач"),
        (type: .normal, title: "Текущая", description: "Задача с обычным приоритетом")
    ]
    
    //выбранный приоритет
    var selectedType: TaskPriority = .normal
    
    var doAfterSelect: ((TaskPriority) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        //регистрация xib ячейки
        let cellTypeNib = UINib(nibName: "TaskTypeCell", bundle: nil)
        tableView.register(cellTypeNib, forCellReuseIdentifier: "TaskTypeCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskTypeInformation.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTypeCell", for: indexPath) as! TaskTypeCell
        let typeDescription = taskTypeInformation[indexPath.row]
        cell.typeTitle.text = typeDescription.title
        cell.typeDescription.text = typeDescription.description
        // если тип является выбранным, то отмечаем галочкой
        if selectedType == typeDescription.type {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedType = taskTypeInformation[indexPath.row].type
        doAfterSelect?(selectedType)
        navigationController?.popViewController(animated: true)
    }

}
