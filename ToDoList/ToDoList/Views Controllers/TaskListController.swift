//
//  TaskListController.swift
//  ToDoList
//
//  Created by Lyubov Menshikova on 18.03.2022.
//

import UIKit
import RealmSwift

class TaskListController: UITableViewController {
    
    
    var tasks: [TaskPriority: [Task]] = [:]
    var sectionsTypesPositions: [TaskPriority] = [.important, .normal]
    var taskList: TaskList!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.name
        loadTasks()
//        var currentTask = taskList.tasks.filter { task in
//            task.status == .planned
//        }
//        var completedTask = taskList.tasks.filter { task in
//            task.status == .completed
//        }
        navigationItem.rightBarButtonItems = [getAddButton(), editButtonItem]
    }
    
    private func loadTasks() {
        sectionsTypesPositions.forEach { taskType in
            tasks[taskType] = []
        }
        
        StorageManager.shared.realm.objects(Task.self).forEach { task in
            tasks[task.priorityEnum]?.append(task)
        }
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
        cell.symbolLabel.text = getSymbolForTask(with: currentTask.statusEnum)
        
        
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        cell.symbolLabel.isUserInteractionEnabled = true
        cell.symbolLabel.addGestureRecognizer(labelTap)
        
        // изменяем цвет текста
        if currentTask.statusEnum == .planned {
            cell.titleLabel.textColor = .black
            cell.symbolLabel.textColor = .black
        } else {
            cell.titleLabel.textColor = .lightGray
        }
        
        return cell
    }
    
    @objc func labelTapped(_ sender: UIGestureRecognizer) {
        let position = sender.location(in: self.tableView)
        guard let index = self.tableView.indexPathForRow(at: position) else {
            print("Error label not in tableView")
            return
        }
        
        self.tableView.beginUpdates()
        defer { self.tableView.endUpdates() }
        
        let taskType = sectionsTypesPositions[index.section]
        guard let _ = tasks[taskType]?[index.row] else { return }
        
        if tasks[taskType]?[index.row].statusEnum == .planned {
            tasks[taskType]?[index.row].statusEnum = .completed
        } else {
            tasks[taskType]?[index.row].statusEnum = .planned
        }
        self.tableView.reloadRows(at: [index], with: .automatic)
        
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
        if segue.identifier == "toTask" {
            guard let dVC = segue.destination as? TaskEditController else { return }
            dVC.doAfterEdit = { [unowned self] title, type, status in
                let task = Task()
                task.title = title
                task.type = type.rawValue
                task.status = status.rawValue
                StorageManager.shared.save(task: task, in: taskList)
            
                tableView.reloadData()
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.setSelected(false, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskType = sectionsTypesPositions[indexPath.section]
        guard let _ = tasks[taskType] else { return nil }
        
        //действие для перехода к экрану редактирования
        let actionEditInstance = UIContextualAction(style: .normal, title: "Редактировать", handler: { _, _, _ in
            let editScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TaskEditController") as! TaskEditController
            editScreen.taskText = self.tasks[taskType]![indexPath.row].title
            editScreen.taskType = self.tasks[taskType]![indexPath.row].priorityEnum
            editScreen.taskStatus = self.tasks[taskType]![indexPath.row].statusEnum
            editScreen.doAfterEdit = { [unowned self] title, type, status in
                let editedTask = Task()
                editedTask.title = title
                editedTask.type = type.rawValue
                editedTask.status = status.rawValue
                StorageManager.shared.edit(task: editedTask, name: title)
                self.tableView.reloadData()
            }
            self.navigationController?.pushViewController(editScreen, animated: true)
        })
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { _, _, _ in
            let task = self.taskList.tasks[indexPath.row]
            StorageManager.shared.delete(task: task)
            self.tasks[taskType]?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        actionEditInstance.backgroundColor = .orange
        
        // добавляем доступные действия в массив
        return UISwipeActionsConfiguration(actions: [actionEditInstance, deleteAction])
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let taskType = sectionsTypesPositions[indexPath.section]
        guard let task = tasks[taskType]?[indexPath.row] else { return }
        StorageManager.shared.delete(task: task)
        tasks[taskType]?.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let taskTypeFrom = sectionsTypesPositions[sourceIndexPath.section]
        let taskTypeTo = sectionsTypesPositions[destinationIndexPath.section]
        
        guard let movedTask = tasks[taskTypeFrom]?[sourceIndexPath.row] else { return }
        
        tasks[taskTypeFrom]!.remove(at: sourceIndexPath.row)
        tasks[taskTypeTo]!.insert(movedTask, at: destinationIndexPath.row)
        
        if taskTypeFrom != taskTypeTo {
            tasks[taskTypeTo]![destinationIndexPath.row].type = taskTypeTo.rawValue
        }
        tableView.reloadData()
    }
    
}
