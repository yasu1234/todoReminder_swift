//
//  TaskListViewController.swift
//  todoReminder
//
//

import UIKit
import RealmSwift
import UserNotifications

class TaskListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var explanation: UILabel!
    var isRegister: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        // Realmのインスタンスを取得
        let realm = try! Realm()
        // Realmに保存されてるDog型のオブジェクトを全て取得
        let tasks = realm.objects(Task.self)
        
        if (tasks.count < 1) {
            explanation.isHidden = true
        }
    }
    
    // 画面遷移時に再描画する
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
        // Realmのインスタンスを取得
        let realm = try! Realm()
        // Realmに保存されてるDog型のオブジェクトを全て取得
        let tasks = realm.objects(Task.self)
        
        if (tasks.count < 1) {
            explanation.isHidden = true
        } else {
            explanation.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Realmのインスタンスを取得
        let realm = try! Realm()
        // Realmに保存されてるDog型のオブジェクトを全て取得
        let tasks = realm.objects(Task.self)
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskListViewCell
        
        // Realmのインスタンスを取得
        let realm = try! Realm()
        // Realmに保存されてるTaskを全て取得
        let tasks = realm.objects(Task.self).sorted(byKeyPath: "createDate", ascending: true)
        let task = tasks[indexPath.row]
        cell.taskName.text = task.taskName
        cell.taskLimit.text = stringFromDate(date: task.taskLimit, format: "yyyy/MM/dd HH:mm")

        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Realmのインスタンスを取得
        let realm = try! Realm()
        let tasks = realm.objects(Task.self).sorted(byKeyPath: "createDate", ascending: true)
        let task = tasks[indexPath.row]
        // 通知削除用のid(データ削除後に通知を削除するため)
        let id = task.id
        if editingStyle == .delete {
            try! realm.write {
                realm.delete(realm.objects(Task.self).filter("id=%@", task.id))
            }
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        
        tableView.reloadData()
        
        if (tasks.count < 1) {
            explanation.isHidden = true
        }
    }
    
    // セルをタップする際にはRealmの情報を編集画面に渡す
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "edit", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Realmのインスタンスを取得
        let realm = try! Realm()
        // Realmに保存されてるDog型のオブジェクトを全て取得
        let tasks = realm.objects(Task.self)
        
        // 編集の場合は登録内容を画面遷移先に渡す
        if segue.identifier == "edit" {
            let indexPath = self.tableView.indexPathForSelectedRow
            let task = tasks[indexPath!.row]
            let vc = segue.destination as! TaskEditViewController
            vc.taskId = task.id
            vc.name = task.taskName
            vc.detail = task.taskDetail
            vc.limit = stringFromDate(date: task.taskLimit, format: "yyyy/MM/dd HH:mm")
            vc.notifyTime = task.notifyTime
            vc.isRegister = false

        } else if segue.identifier == "register" {
            if (tasks.count >= 5) {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                alert.title = "5件までしか登録できません"
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                }))
                self.present(alert,animated: true,completion: {print("アラート表示")})
            } else {
                let vc = segue.destination as! TaskEditViewController
                vc.isRegister = true
            }
        }
    }
    
    // Date型の日付を文字列にする
    func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
