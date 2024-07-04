//
//  TodoRepository.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/4/24.
//

import UIKit
import RealmSwift

final class TodoRepository {
    private let realm = try! Realm()
    
    func createItem(_ data: Todo)  {
        do {
            try realm.write {
                realm.add(data)
            }
        } catch {
            print("저장 실패!")
        }
    }
    
    func readAllItem() -> [Todo] {
        return Array(realm.objects(Todo.self))
    }
    
    func readFilteredItem(_ filter: ReminderCase) -> [Todo] {
        let allData = readAllItem()
        switch filter {
        case .today:
            return allData.filter { Date.dateCompare(deadline: $0.deadline) == .today }
        case .schedule:
            return allData.filter { Date.dateCompare(deadline: $0.deadline) == .future }
        case .all:
            return allData
        case .flag:
            return allData.filter { $0.isFlag }
        case .complete:
            return allData.filter { $0.isComplete }
        }
    }
    
    
    func updateItem(_ completionHandler: () -> Void)  {
        do {
            try realm.write {
                completionHandler()
            }
        } catch {
            print("업데이트 실패!")
        }
    }
    
    func deleteItem(_ id: ObjectId) {
        do {
            try realm.write {
                guard let item = realm.object(ofType: Todo.self, forPrimaryKey: id) else { return }
                realm.delete(item)
            }
        } catch {
            print("삭제 실패!")
        }
    }
}
