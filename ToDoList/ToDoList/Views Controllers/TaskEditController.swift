//
//  TaskEditController.swift
//  ToDoList
//
//  Created by Lyubov Menshikova on 21.03.2022.
//

import UIKit

class TaskEditController: UITableViewController {
    
    @IBOutlet var taskTitle: UITextField!
    @IBOutlet var taskTypeLabel: UILabel!
    @IBOutlet var taskStatusSwitch: UISwitch!
    
    var taskText: String = ""
    var taskType: TaskPriority = .normal
    var taskStatus: TaskStatus = .planned
    
    var doAfterEdit: ((String, TaskPriority, TaskStatus) -> Void)?
    
    private var taskTitles: [TaskPriority: String] = [
        .important: "Важная",
        .normal: "Текущая"
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTitle?.text = taskText
        taskTypeLabel?.text = taskTitles[taskType]
        
        //switch
        if taskStatus == .completed {
            taskStatusSwitch.isOn = true
        }
    }
    
    @IBAction func saveTaskButtonPressed(_ sender: UIBarButtonItem) {
        let title = taskTitle?.text ?? ""
        if title == "" || title.first == " " {
            showAlert()
            return
        }
        let type = taskType
        let status: TaskStatus = taskStatusSwitch.isOn ? .completed : .planned
        doAfterEdit?(title,type,status)
        navigationController?.popViewController(animated: true)
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "Ошибка", message: "Поле \("'Введите задачу'") должно быть заполнено", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTaskType" {
            guard let dVC = segue.destination as? TaskTypeController else { return }
            dVC.selectedType = taskType
            dVC.doAfterSelect = { [unowned self] selectedType in
                self.taskType = selectedType
                self.taskTypeLabel.text = taskTitles[taskType]
            }
        }
    }
    
    //MARK: снимание выделения при отжатии ячейки
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.setSelected(false, animated: true)
    }

}
