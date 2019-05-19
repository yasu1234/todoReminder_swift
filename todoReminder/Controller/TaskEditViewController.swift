//
//  TaskEditViewController.swift
//  todoReminder
//
//

import UIKit
import RealmSwift
import UserNotifications

class TaskEditViewController: UIViewController {

    @IBOutlet var taskName: UITextField!
    @IBOutlet var taskLimit: UITextField!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var taskDetail: UITextView?
    
    var taskId: String?
    var name: String!
    var detail: String?
    var limit: String!
    var isRegister: Bool = true
    
    var datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 登録時は削除ボタンを非表示
        if (isRegister) {
            deleteButton.isHidden = true
        }

        // 枠のカラー
        taskDetail?.layer.borderColor = UIColor.black.cgColor
        // 枠の幅
        taskDetail?.layer.borderWidth = 1.0
        
        taskName.text = name
        taskDetail?.text = detail
        taskLimit.text = limit
        
        // デートピッカー作成
        createDatePicker()
    }
    
    // デートピッカーでOKボタンを押したときの処理
    @objc func done() {
        taskLimit.endEditing(true)

        // 日付のフォーマット
        let formatter = DateFormatter()

        //表示形式をyyyy/MM/dd HH:mmにする
        formatter.dateFormat = "yyyy/MM/dd HH:mm"

        //datePickerで指定した日付が表示される
        taskLimit.text = "\(formatter.string(from: datePicker.date))"
    }
    
    // 入力が終わったらキーボードを隠す
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        let now = Date()
        
        if (taskName.text == "" || taskLimit.text == "") {
            makeAlert(title: "タスク名とタスク期限は必須です", isAddAction: false)
        } else if (now > dateFormat(stringDate: taskLimit.text!)) {
            makeAlert(title: "現在より少なくとも1分後を指定して下さい", isAddAction: false)
        } else {
            let realm = try! Realm()
            let task : Task
            if (isRegister) {
                task = Task()
            } else {
                task = realm.objects(Task.self).filter("id=%@", taskId!).first!
            }

            try! realm.write() {
                task.taskName = taskName.text!
                task.taskDetail = taskDetail?.text ?? ""
                task.taskLimit = dateFormat(stringDate: taskLimit.text!)
                realm.add(task)
                print(task)
            }
            
            self.navigationController?.popViewController(animated: true)
            
            // 通知の作成
            createNotification(task: task)
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        let task = Task()
        task.id = taskId!
        let realm = try! Realm()
        
        try! realm.write {
            realm.delete(realm.objects(Task.self).filter("id=%@", task.id))
        }
        // 通知の削除
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id])
        
        makeAlert(title: "削除しました", isAddAction: true)
    }
    
    // デートピッカーの作成
    func createDatePicker() {
        datePicker.date = Date()
        datePicker.datePickerMode = .dateAndTime
        datePicker.locale = Locale(identifier: "ja")
        
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        // textFieldに表示するようにする
        taskLimit.inputView = datePicker
        taskLimit.inputAccessoryView = toolbar
    }
    
    // 文字列をDate型に変換する
    func dateFormat(stringDate: String) -> Date! {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let date = dateFormatter.date(from: stringDate)
        return date
    }
    
    // アラートを作成する
    func makeAlert(title: String, isAddAction: Bool) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = title
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if (isAddAction) {
                self.navigationController?.popViewController(animated: true)
            }
        }))
        self.present(alert,animated: true,completion: {print("アラート表示")})
    }
    
    func createNotification(task : Task) {
        let content = UNMutableNotificationContent()
        content.title = "時間です"
        content.subtitle = task.taskName
        content.body = "タップしたらアプリを起動します"
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.taskLimit)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: task.id, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}

