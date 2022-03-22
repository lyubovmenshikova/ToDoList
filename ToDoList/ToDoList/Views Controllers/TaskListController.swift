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
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = getAddButton()
        
        setupStatusBar()
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
    
    private func getAddButton() -> UIBarButtonItem {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(addButtonPressed))
        return addButton
    }
    
    @objc private func addButtonPressed() {
        performSegue(withIdentifier: "toTask", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dVC = segue.destination as? TaskEditController else { return }
        dVC.doAfterEdit = { [unowned self] title, type, status in
            let newTask = Task(title: title, type: type, status: status)
            self.tasks[type]?.append(newTask)
            self.tableView.reloadData()
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskType = sectionsTypesPositions[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else { return }
        guard tasks[taskType]![indexPath.row].status == .planned else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        //ставим задачу как выполненную
        tasks[taskType]![indexPath.row].status = .completed
        //перезагружаем таблицу
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
    }
    
    
    private func setupStatusBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 34/255, green: 191/255, blue: 181/255, alpha: 1)
        appearance.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 21.0),
                                          .foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }


}
