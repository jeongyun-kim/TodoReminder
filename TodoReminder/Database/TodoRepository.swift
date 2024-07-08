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
    
    func readAllItems(_ sortType: Resource.ListSortType = .dateAsc) -> Results<Todo> {
        let sortType = sortType == .dateAsc
        // savedate를 기준으로 오름차순 = true / 내림차순 = false
        return realm.objects(Todo.self).sorted(byKeyPath: "savedate", ascending: sortType)
    }
    
    func readFilteredItem(_ filter: ReminderCase, sort: Resource.ListSortType = .dateAsc) -> [Todo] {
        let allData = Array(readAllItems(sort))
        switch filter {
        case .today:
            return allData.filter { Date.dateCompare(deadline: $0.deadline) == .today}
        case .schedule:
            return allData.filter { Date.dateCompare(deadline: $0.deadline) == .future }
        case .all:
            return allData
        case .flag:
            return allData.filter { $0.isFlag }
        case .complete:
            return allData.filter { $0.isComplete }
        case .bookmark:
            return allData.filter { $0.isBookmark }
        }
    }
    
    func readSearchedItem(list: [Todo], keyword: String) -> [Todo]{
        // 받아온 리스트
        let originalListSet = Set(list)
        // 전체 리스트에서 제목, 메모에 키워드가 포함된 검색결과 받아오기
        let searchedListSet = Set(readAllItems()
            .where { $0.todoTitle.contains(keyword, options: .caseInsensitive)
                || $0.memo.contains(keyword, options: .caseInsensitive) })
        // 받아온 리스트랑 전체 내 검색결과의 교집합으로 구성해주기 (= 리스트 내 검색 결과를 구할 수 있음)
        let result = originalListSet.intersection(searchedListSet)
        return Array(result)
    }
    
    func readFilteredDateItem(_ calendarDate: Date) -> [Todo] {
        // 전체 데이터 가져와서
        let allData = Array(readAllItems())
        // 마감일이 nil이 아닌 Todo목록만 가져오기
        let nonNilDeadline = allData.filter { $0.deadline != nil }
        // 그 중에서 FSCalendar에서 선택한 날짜랑 마감일이 같은 경우의 Todo목록만 가져와 반환하기 
        let result = nonNilDeadline
            .filter { Date.dateFormattedString($0.deadline!) == Date.dateFormattedString(calendarDate) }
        return result
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


