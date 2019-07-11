//
//  TaskEditViewController.swift
//  todoReminder
//
//

import UIKit
import RealmSwift
import UserNotifications

class TaskEditViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet var taskName: UITextField!
    @IBOutlet var taskLimit: UITextField!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var taskDetail: UITextView?
    @IBOutlet var taskNotifyTime: UITextField!
    
    var taskId: String?
    var name: String!
    var detail: String?
    var limit: String!
    var notifyTime: String?
    var isRegister: Bool = true
    
    var datePicker = UIDatePicker()
    
    var pickerView = UIPickerView()
    // 選択肢
    let list: [NotifyTime] = [.UNSELECT, .FIVE, .TEN, .FIFTEEN, .THIRTEEN, .HOUR]
    
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
        
        // 通知時間のピッカーを作成する
        createSelectPicker()
        
        // データが登録されていない場合は選択なしで表示させる
        self.taskNotifyTime.text = list[Int(notifyTime ?? "0")!].rawValue

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // 選択肢の数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    // 選択肢を表示させる
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.taskNotifyTime.text = list[row].rawValue
    }
    
    // ピッカーの選択肢
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row].rawValue
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
    
    // 通知時間選択でOKボタンを押したときの処理
    @objc func decide() {
        taskNotifyTime.endEditing(true)
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
                task.notifyTime = createNotifyTimeCode(code: taskNotifyTime.text ?? NotifyTime.UNSELECT.rawValue)
                realm.add(task)
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
    
    // 通知時間の選択肢の作成
    func createSelectPicker() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(decide))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        // textFieldに表示するようにする
        taskNotifyTime.inputView = pickerView
        taskNotifyTime.inputAccessoryView = toolbar
    }
    
    // 文字列をDate型に変換する
    func dateFormat(stringDate: String) -> Date! {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let date = dateFormatter.date(from: stringDate)
        return date
    }
    
    // 設定文言から登録用のコード値を取得
    func createNotifyTimeCode(code: String) -> String {
        switch code {
        case NotifyTime.UNSELECT.rawValue:
            return "0"
        case NotifyTime.FIVE.rawValue:
            return "1"
        case NotifyTime.TEN.rawValue:
            return "2"
        case NotifyTime.FIFTEEN.rawValue:
            return "3"
        case NotifyTime.THIRTEEN.rawValue:
            return "4"
        case NotifyTime.HOUR.rawValue:
            return "5"
        default:
            return "0"
        }
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
        content.title = "設定した時間です"
        content.subtitle = task.taskName
        content.body = "タップしたらアプリを起動します"
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        // 期限の何分前に通知するかを設定する
        let time = createNotifyTime(task: task)
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: time!)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: task.id, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    // 通知時間を期限から設定し直す
    func createNotifyTime(task: Task) -> Date! {
        switch task.notifyTime {
        case "0":
            return Calendar.current.date(byAdding: .minute, value: 0, to: task.taskLimit)
        case "1":
            return Calendar.current.date(byAdding: .minute, value: -5, to: task.taskLimit)
        case "2":
            return Calendar.current.date(byAdding: .minute, value: -10, to: task.taskLimit)
        case "3":
            return Calendar.current.date(byAdding: .minute, value: -15, to: task.taskLimit)
        case "4":
            return Calendar.current.date(byAdding: .minute, value: -30, to: task.taskLimit)
        case "5":
            return Calendar.current.date(byAdding: .hour, value: -1, to: task.taskLimit)
        default:
            return Calendar.current.date(byAdding: .minute, value: 0, to: task.taskLimit)
        }
    }
}

