//
//  TodoList.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/3/24.
//

import Foundation
import RealmSwift

class TodoList: Object {
    @Persisted (primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var imageName: String
    @Persisted var tintColor: String
    @Persisted var todos: List<Todo>
    
    convenience init(listName: String, imageName: String, tintColor: String) {
        self.init()
        self.title = listName
        self.imageName = imageName
        self.tintColor = tintColor
    }
}

extension TodoList {
   var defaultTodoList: [TodoList] {
       return [
        TodoList(listName: ReminderCase.today.title, imageName: ReminderCase.today.imageName, tintColor: ReminderCase.today.imageColor),
        TodoList(listName: ReminderCase.schedule.title, imageName: ReminderCase.schedule.imageName, tintColor: ReminderCase.schedule.imageColor),
        TodoList(listName: ReminderCase.all.title, imageName: ReminderCase.all.imageName, tintColor: ReminderCase.all.imageColor),
        TodoList(listName: ReminderCase.flag.title, imageName: ReminderCase.flag.imageName, tintColor: ReminderCase.flag.imageColor),
        TodoList(listName: ReminderCase.complete.title, imageName: ReminderCase.complete.imageName, tintColor:ReminderCase.complete.imageColor),
        TodoList(listName: ReminderCase.bookmark.title, imageName: ReminderCase.bookmark.imageName, tintColor: ReminderCase.bookmark.imageColor)
        ]
    }
}
