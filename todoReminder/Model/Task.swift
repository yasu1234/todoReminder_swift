//
//  Task.swift
//  todoReminder
//
//

import Foundation
import RealmSwift

class Task: Object {
    
    @objc dynamic var id : String = NSUUID().uuidString
    @objc dynamic var taskName : String = ""
    @objc dynamic var taskDetail : String = ""
    @objc dynamic var taskLimit = Date()
    @objc dynamic var createDate = Date()
    
    // IDをプライマリキーにする
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func delete() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(self)
        }
    }
}
