//
//  TodoList.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/3/24.
//

import Foundation
import RealmSwift


struct TodoList {
    let filter: ReminderCase

    var listCnt: Int {
        TodoRepository().readFilteredItem(filter).count
    }
}

extension TodoList {
   static var list: [TodoList] {
       return [
            TodoList(filter: .today),
            TodoList(filter: .schedule),
            TodoList(filter: .all),
            TodoList(filter: .flag),
            TodoList(filter: .complete),
            TodoList(filter: .bookmark)
        ]
    }
}
