//
//  Todo.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import Foundation
import RealmSwift

class Todo: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var memo: String?
    @Persisted var deadline: Date?
    @Persisted var tag: String?
    @Persisted var priority: String?
    @Persisted var imageName: String?
    @Persisted var isFlag: Bool
    @Persisted var isComplete: Bool
    @Persisted var savedate: Date
    
    convenience init(title: String, memo: String? = nil, deadline: Date? = nil, tag: String? = nil, priority: String? = nil, imageName: String? = nil, savedate: Date) {
        self.init()
        self.title = title
        self.memo = memo
        self.deadline = deadline
        self.tag = tag
        self.priority = priority
        self.imageName = imageName
        self.isFlag = false
        self.isComplete = false
        self.savedate = savedate
    }
}
