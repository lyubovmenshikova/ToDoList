//
//  ListViewController.swift
//  ToDoList
//
//  Created by Lyubov Menshikova on 25.03.2022.
//

import UIKit

class ListViewController: UITableViewController {
    
    var lists: [TaskListProtocol] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStatusBar()
    }
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        self.showALert(withTitle: "Новый список задач", message: "Введите значение, пожалуйста", taskList: nil)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListViewCell
        let taskList = lists[indexPath.row]
        
        let currentTask = taskList.tasks.filter { task in
            task.status == .planned
        }
        let comletedTask = taskList.tasks.filter { task in
            task.status == .completed
        }
        
        cell.titleLabel.text = taskList.name
        
        if !currentTask.isEmpty {
            cell.detailLabel.text = "\(currentTask.count)"
            cell.accessoryType = .none
        } else if !comletedTask.isEmpty {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
            cell.detailLabel.text = "0"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskList = lists[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { _, _, _ in
           // удалить из хранилища
            self.lists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }

        let editAction = UIContextualAction(style: .normal, title: "Изменить") { (_, _, isDone) in
            self.showALert(withTitle: "Редактировать список", message: "Введите новое значение", taskList: taskList)
//            self.showALert(taskList: taskList) {
//                tableView.reloadRows(at: [indexPath], with: .automatic)
//            }
            isDone(true)
        }
//
//        let doneAction = UIContextualAction(style: .normal, title: "Ок") { _, _, isDone in
//            taskList.tasks[indexPath.row].status = .completed
//            tableView.reloadRows(at: [indexPath], with: .automatic)
//            isDone(true)
//        }
//        editAction.backgroundColor = .orange
//        doneAction.backgroundColor = .green

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
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

extension ListViewController {
    
    private func showALert(withTitle: String, message: String, taskList: TaskListProtocol?) {
        
        let alert = UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
        
        if let taskList = taskList {
            let saveAction = UIAlertAction(title: "Изменить", style: .destructive) { _ in
                //taskList.name = alert.textFields?.first?.text
            }
            alert.addAction(saveAction)
        } else {
            let editAction = UIAlertAction(title: "Сохранить", style: .destructive) { _ in
                guard let task = alert.textFields?.first?.text else { return }
                let newTaskList = TaskList(name: task, date: .now, tasks: [])
                self.lists.append(newTaskList)
                self.tableView.reloadData()
            }
            alert.addAction(editAction)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "Новый список"
            textField.text = taskList?.name
        }
        
        present(alert, animated: true, completion: nil)
        
       
//        alert.editAction(with: taskList) { [unowned self] newValue in
//            if let taskList = taskList, let completion = completion {
//                taskList.name = newValue
//                let editTask = TaskList(name: newValue, date: .now, tasks: [])
//                lists.insert(editTask, at: 0)
//                let rowIndex = IndexPath(row: self.lists.count - 1, section: 0)
//                self.tableView.insertRows(at: [rowIndex], with: .automatic)
//               // taskList.name = newValue
//                // редактирование StorageManager.shared.edit(taskList: taskList, newValue: newValue)
//                completion()
//            } else {
//                //создаем новый список
//
//                let taskList = TaskList(name: newValue, date: .now, tasks: [])
//                self.lists.append(taskList)
//                //сохраняем список в базу данных
//                // StorageManager.shared.save(taskList: taskList)
//
//                let rowIndex = IndexPath(row: self.lists.count - 1, section: 0)
//                //вставляем новый список в табицу по индексу
//                self.tableView.insertRows(at: [rowIndex], with: .automatic)
//            }
//
//        }

    }
    
    
}
