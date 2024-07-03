//
//  TodoList.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/3/24.
//

import Foundation
import RealmSwift


struct TodoList {
    let listCase: ReminderCase
}

extension TodoList {
   static var list: [TodoList] {
       return [
            TodoList(listCase: .today),
            TodoList(listCase: .schedule),
            TodoList(listCase: .all),
            TodoList(listCase: .flag),
            TodoList(listCase: .complete)
        ]
    }
}
