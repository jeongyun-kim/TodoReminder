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
    @Persisted var content: String?
    @Persisted var deadline: Date?
    @Persisted var tag: String?
    @Persisted var priority: String?
    @Persisted var imageName: String?
    @Persisted var isFlag: Bool
    @Persisted var isComplete: Bool
    @Persisted var savedate: Date
    
    convenience init(id: ObjectId, title: String, content: String? = nil, deadline: Date? = nil, tag: String? = nil, priority: String? = nil, imageName: String? = nil, savedate: Date) {
        self.init()
        self.title = title
        self.content = content
        self.deadline = deadline
        self.tag = tag
        self.priority = priority
        self.imageName = imageName
        self.isFlag = false
        self.isComplete = false
        self.savedate = savedate
    }
}
