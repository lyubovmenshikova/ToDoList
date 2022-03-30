//
//  TaskListController.swift
//  ToDoList
//
//  Created by Lyubov Menshikova on 18.03.2022.
//

import UIKit
import RealmSwift

class TaskListController: UITableViewController {
    
    
    var taskList: TaskList!
   
    var tasks = StorageManager.shared.realm.objects(Task.self)
    var currentTask: Results<Task>!
    var importantTask: Results<Task>!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.name
        
        currentTask = taskList.tasks.where({ $0.type == .normal })
        importantTask = taskList.tasks.where({ $0.type == .important })
        
        navigationItem.rightBarButtonItems = [getAddButton(), editButtonItem]
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "ВАЖНЫЕ" : "ТЕКУЩИЕ"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tasks.count != 0 {
            return section == 0 ? importantTask.count : currentTask.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskListCell", for: indexPath) as! TaskViewCell
        let task = indexPath.section == 0 ? importantTask[indexPath.row] : currentTask[indexPath.row]
        
        cell.titleLabel.text = task.title
        cell.symbolLabel.text = getSymbolForTask(with: task.status)
        
        
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        cell.symbolLabel.isUserInteractionEnabled = true
        cell.symbolLabel.addGestureRecognizer(labelTap)
        
        // изменяем цвет текста
        if task.status == .planned {
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
        
        let task = index.section == 0 ? importantTask[index.row] : currentTask[index.row]
        
        if task.status == .planned {
            let name = task.title
            let type = task.type
            let status = TaskStatus.completed
            StorageManager.shared.edit(task: task, name: name, type: type, status: status)
        } else {
            let name = task.title
            let type = task.type
            let status = TaskStatus.planned
            StorageManager.shared.edit(task: task, name: name, type: type, status: status)
        }
        self.tableView.reloadData()
        
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
                task.type = type
                task.status = status
                StorageManager.shared.save(task: task, in: self.taskList)
                
                tableView.reloadData()
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.setSelected(false, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == 0 ? importantTask[indexPath.row] : currentTask[indexPath.row]
        
        //действие для перехода к экрану редактирования
        let actionEditInstance = UIContextualAction(style: .normal, title: "Редактировать", handler: { _, _, _ in
            let editScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TaskEditController") as! TaskEditController
            editScreen.taskText = task.title
            editScreen.taskType = task.type
            editScreen.taskStatus = task.status
            editScreen.doAfterEdit = { [unowned self] title, type, status in
                StorageManager.shared.edit(task: task, name: title, type: type, status: status)
                self.tableView.reloadData()
            }
            self.navigationController?.pushViewController(editScreen, animated: true)
        })
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { _, _, _ in
            let task = self.taskList.tasks[indexPath.row]
            StorageManager.shared.delete(task: task)
            // self.tasks[taskType]?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        actionEditInstance.backgroundColor = .orange
        
        // добавляем доступные действия в массив
        return UISwipeActionsConfiguration(actions: [deleteAction, actionEditInstance])
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.none
    }
    
    
//    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        
//        let newTask = Task()
//        newTask.title = taskList.tasks[sourceIndexPath.row].title
//        newTask.status = taskList.tasks[sourceIndexPath.row].status
//        newTask.type = destinationIndexPath.section == 0 ? TaskPriority.important : TaskPriority.normal
//        
//        StorageManager.shared.move(task: newTask, in: taskList, indexPathFrom: sourceIndexPath, indexPathTo: destinationIndexPath)
//        
//        tableView.reloadData()
//    }
    
}
