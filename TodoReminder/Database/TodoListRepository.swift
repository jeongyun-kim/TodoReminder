//
//  TodoListRepository.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/8/24.
//

import Foundation
import RealmSwift

class TodoListRepository {
    private let realm = try! Realm()
    
    // 투두리스트 목록 생성
    func createList(_ data: TodoList) {
        do {
            try realm.write {
                realm.add(data)
            }
        } catch {
            print("List Create Error")
        }
    }
    
    // 투두리스트 목록 데이터 모두 가져오기
    func readAll() -> [TodoList] {
        return Array(realm.objects(TodoList.self))
    }
    
    // 투두리스트 목록 데이터 업데이트
    // - 할 일 추가하기를 통해 새로운 할 일이 생겼을 때 또는 할 일을 편집했을 때, 바뀐 데이터를 반영하기 위해 각 목록에 투두리스트 업데이트
    func updateList(_ todoList: TodoList, list: List<Todo>) {
        let value: [String:Any] = ["id": todoList.id, "todos": list]
        do {
            try realm.write {
                realm.create(TodoList.self, value: value, update: .modified)
            }
        } catch {
            print("List Update Error")
        }
    }
}
