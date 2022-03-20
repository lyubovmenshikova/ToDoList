//
//  TaskListController.swift
//  ToDoList
//
//  Created by Lyubov Menshikova on 18.03.2022.
//

import UIKit

class TaskListController: UITableViewController {
    
    var tasks: [TaskPriority: [TaskProtocol]] = [.normal:[Task(title: "Hello", type: .normal, status: .planned), Task(title: "Bye", type: .normal, status: .completed)], .important:[Task(title: "iii", type: .normal, status: .planned)]]
    var sectionsTypesPositions: [TaskPriority] = [.important, .normal]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController!.view.backgroundColor = UIColor.clear
        navigationItem.leftBarButtonItem = editButtonItem
        //navigationItem.rightBarButtonItem =
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let taskType = sectionsTypesPositions[section]
        guard let taskArray = tasks[taskType] else { return 0 }
        return taskArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskListCell", for: indexPath) as! TaskViewCell
        let taskType = sectionsTypesPositions[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else { return cell }
        
        cell.titleLabel.text = currentTask.title
        cell.symbolLabel.text = getSymbolForTask(with: currentTask.status)
        
        // изменяем цвет текста
        if currentTask.status == .planned {
            cell.titleLabel.textColor = .black
            cell.symbolLabel.textColor = .black
        } else {
            cell.titleLabel.textColor = .lightGray
        }
       
        return cell
    }
    
    //символ для задачи
    private func getSymbolForTask(with status: TaskStatus) -> String {
        var result: String
        if status == .planned {
            result = "\u{25CB}"
        } else if status == .completed {
            result = "\u{2713}"
        } else {
            result = ""
        }
        return result
    }
    
    //заголовок секции
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        let taskType = sectionsTypesPositions[section]
        if taskType == .important {
            title = "ВАЖНЫЕ"
        } else if taskType == .normal {
            title = "ТЕКУЩИЕ"
        }
        return title
    }
    
    //цвет текста секции
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .black
    }
    

}
