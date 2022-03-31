//
//  ListViewController.swift
//  ToDoList
//
//  Created by Lyubov Menshikova on 25.03.2022.
//

import UIKit
import RealmSwift

class ListViewController: UITableViewController {
    
    var lists: Results<TaskList>!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lists = StorageManager.shared.realm.objects(TaskList.self)
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
        
        let currentTask = taskList.tasks.where { $0.status == .planned }
        let comletedTask = taskList.tasks.where { $0.status == .completed }
        
        cell.titleLabel.text = taskList.name
        
        if !currentTask.isEmpty {
            cell.detailLabel.text = "\(currentTask.count)"
            cell.accessoryType = .none
        } else if !comletedTask.isEmpty {
            cell.detailLabel.text = ""
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
            StorageManager.shared.delete(taskList: taskList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Изменить") { (_, _, isDone) in
            self.showALert(withTitle: "Редактировать список", message: "Введите новое значение", taskList: taskList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        editAction.backgroundColor = .orange
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let destinationVC = segue.destination as! TaskListController
        destinationVC.taskList = lists[indexPath.row]
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
    
    private func showALert(withTitle: String, message: String, taskList: TaskList?, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
        
        if let taskList = taskList {
            let saveAction = UIAlertAction(title: "Изменить", style: .destructive) { _ in
                guard let newValue = alert.textFields?.first?.text else { return }
                StorageManager.shared.edit(taskList: taskList, newValue: newValue)
                completion?()
            }
            alert.addAction(saveAction)
        } else {
            let editAction = UIAlertAction(title: "Сохранить", style: .destructive) { _ in
                guard let task = alert.textFields?.first?.text else { return }
                let taskList = TaskList()
                taskList.name = task
                StorageManager.shared.save(taskList: taskList)
                
                let rowIndex = IndexPath(row: self.lists.count - 1, section: 0)
                self.tableView.insertRows(at: [rowIndex], with: .automatic)
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
        
    }
    
    
}
