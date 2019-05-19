//
//  TaskListViewCell.swift
//  todoReminder
//
//

import UIKit

class TaskListViewCell: UITableViewCell {
    
    
    @IBOutlet var taskName: UILabel!
    
    @IBOutlet var taskLimit: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
