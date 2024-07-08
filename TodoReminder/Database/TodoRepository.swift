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
    private let listRepo = TodoListRepository()
    
    func createItem(_ data: Todo)  {
        var list: TodoList?
        let todoList = listRepo.readAll()
        
        switch Date.dateCompare(deadline: data.deadline) {
        case .future:
            list = todoList.filter({ $0.listName == ReminderCase.schedule.title }).first
        case .today:
            list = todoList.filter({ $0.listName == ReminderCase.today.title }).first
        default:
            list = todoList.filter({ $0.listName == ReminderCase.all.title }).first
        }
        
        do {
            try realm.write {
                if let list {
                    list.filteredList.append(data)
                }
            }
        } catch {
            print("저장 실패!")
        }
    }
    
    func readAllItems() -> Results<Todo> {
        return realm.objects(Todo.self)
    }

    func readFilteredTodo(_ listName: String) -> List<Todo> {
        let allData = Array(readAllItems())
        var arrayFilteredTodo: [Todo] = []
        let listFilteredTodo: List<Todo> = List()
   
        // 각 투두리스트 목록의 이름에 따라 다른 필터링 데이터 던져주기
        switch listName {
            // 목록명이 "오늘"이라면
        case ReminderCase.today.title:
            arrayFilteredTodo = allData.filter { Date.dateCompare(deadline: $0.deadline) == .today}
            // 목록명이 "예정"이라면
        case ReminderCase.schedule.title:
            arrayFilteredTodo = allData.filter { Date.dateCompare(deadline: $0.deadline) == .future }
            // 목록명이 "전체"라면
        case ReminderCase.all.title:
            arrayFilteredTodo = allData
            // 목록명이 "깃발표시"라면
        case ReminderCase.flag.title:
            arrayFilteredTodo = allData.filter { $0.isFlag }
            // 목록명이 "완료됨"이라면
        case ReminderCase.complete.title:
            arrayFilteredTodo = allData.filter { $0.isComplete }
            // 목록명이 "즐겨찾기"라면
        case ReminderCase.bookmark.title:
            arrayFilteredTodo = allData.filter { $0.isBookmark }
        default :
            break
        }
        
        // 배열로 가져온 데이터 List로
        for todo in arrayFilteredTodo {
            listFilteredTodo.append(todo)
        }
        return listFilteredTodo
    }
    
    func readSearcedTodo(list: List<Todo>, keyword: String) -> [Todo] {
        let result = list.where { $0.todoTitle.contains(keyword, options: .caseInsensitive) || $0.memo.contains(keyword, options: .caseInsensitive)}
        return Array(result)
    }
    
    func readSelectedDateTodo(_ calendarDate: Date) -> [Todo] {
        // 전체 데이터 가져와서
        let allData = Array(readAllItems())
        // 마감일이 nil이 아닌 Todo목록만 가져오기
        let nonNilDeadline = allData.filter { $0.deadline != nil }
        // 그 중에서 FSCalendar에서 선택한 날짜랑 마감일이 같은 경우의 Todo목록만 가져와 반환하기 
        let result = nonNilDeadline
            .filter { Date.dateFormattedString($0.deadline!) == Date.dateFormattedString(calendarDate) }
        return result
    }
    
    func readSortedTodo(_ list: List<Todo>, ascending: Bool) -> [Todo]{
        return Array(list.sorted(byKeyPath: "savedate", ascending: ascending))
    }
    
    func updateTodo(_ completionHandler: () -> Void)  {
        do {
            try realm.write {
                completionHandler()
            }
        } catch {
            print("업데이트 실패!")
        }
    }
    
    func deleteTodo(_ id: ObjectId) {
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


