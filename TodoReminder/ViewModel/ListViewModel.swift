//
//  ListViewModel.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/11/24.
//

import Foundation

final class ListViewModel {
    private let repository = TodoRepository()
    private let document = DocumentManager.shared
    
    // Input
    // 원본의 투두리스트 자체 정보
    // 뷰 진입 시 변화 한 번
    var originalTodoList: Observable<TodoList?> = Observable(nil)
    // 검색 끝나고 다시 데이터 넣어줘야할 때
    var inActivedSeachController: Observable<Void?> = Observable(nil)
    var completeTrigger: Observable<Int> = Observable(0)
    var flagTrigger: Observable<Int> = Observable(0)
    var bookmarkTrigger: Observable<Int> = Observable(0)
    var sortTrigger: Observable<Bool> = Observable(false)
    var searchTrigger: Observable<String?> = Observable("")
    var deleteTodoTrigger: Observable<Int> = Observable(0)
    
    // Output
    // 원본의 할 일 목록을 정렬해 검색이 끝났을 때, 정렬이 유지된 채로 할 일들이 다시 그려지기 위해 사용
    // 정렬 기능을 사용하지 않은 상태에서 그냥 검색을 눌렀다가 취소할수도 있기 때문에 옵셔널로 관리
    // -> VC에서 실질적인 사용은 X
    var sortedOriginalTodos: Observable<[Todo]> = Observable([])
    // 정렬, 검색 결과 등을 담아 실질적으로 테이블뷰를 그리는데 사용되는 할 일 목록
    var filteredTodos: Observable<[Todo]> = Observable([])
    // idx: reload할 cell의 순번 -> VC에서 cell reload
    var reloadCell: Observable<Int> = Observable(0)
    
    init() { transform() }
        
    private func transform() {
        inputOriginalTodoLists()
        updateTodoData()
        searchTriggers()
        
        sortTrigger.bind { ascType in
            guard let originalTodoList = self.originalTodoList.value else { return }
            let originalTodos = originalTodoList.filteredList
            let sortedTodos = self.repository.readSortedTodo(originalTodos, ascending: ascType)
            self.sortedOriginalTodos.value = sortedTodos
            self.filteredTodos.value = sortedTodos
        }
        
        deleteTodoTrigger.bind { idx in
            let todoToDelete = self.filteredTodos.value[idx]
            var sortedTodos = self.sortedOriginalTodos.value
            sortedTodos.removeAll { $0.id == todoToDelete.id }
            // 이미지 도큐먼트에서 삭제
            if let imageName = todoToDelete.imageName {
                self.document.removeImageFromDocument(imageName: imageName)
            }
            self.repository.deleteTodo(todoToDelete.id)
            self.sortedOriginalTodos.value = sortedTodos
        }
        
    }
    
    private func inputOriginalTodoLists() {
        originalTodoList.bind { _ in
            guard let originalTodoList = self.originalTodoList.value else { return }
            let originalTodos = originalTodoList.filteredList
            self.filteredTodos.value = Array(originalTodos)
            self.sortedOriginalTodos.value = Array(originalTodos)
        }
    }

    private func updateTodoData() {
        // 할 일 완료 처리 -> VC에서는 해당 idx의 셀만 reload
        // 만약 완료됨 리스트뷰인데, 완료됨을 해제했다면? -> 테이블뷰 그려주는 리스트에서 해당 데이터 제거
        completeTrigger.bind { idx in
            let data = self.filteredTodos.value[idx]
            
            self.repository.updateTodo {
                data.isComplete.toggle()
            }
            
            if !data.isComplete {
                self.removeFalseData(.complete, idx: idx)
            }
            self.reloadCell.value = idx
        }
        
        bookmarkTrigger.bind { idx in
            let data = self.filteredTodos.value[idx]
       
            self.repository.updateTodo {
                data.isBookmark.toggle()
            }

            if !data.isBookmark {
                self.removeFalseData(.bookmark, idx: idx)
            }
            self.reloadCell.value = idx
        }
        
        flagTrigger.bind { idx in
            let data = self.filteredTodos.value[idx]
            
            self.repository.updateTodo {
                data.isFlag.toggle()
            }
            
            if !data.isFlag {
                self.removeFalseData(.flag, idx: idx)
            }
            self.reloadCell.value = idx
        }
    }
    
    private func searchTriggers() {
        inActivedSeachController.bind { _ in
            let sortedTodos = self.sortedOriginalTodos.value
            // 정렬되어있던 찐리스트 넣어주기
            self.filteredTodos.value = sortedTodos
        }
        
        searchTrigger.bind { keyword in
            if let keyword, let originalTodoList = self.originalTodoList.value {
                let originalTodos = originalTodoList.filteredList
                let searchedTodos = self.repository.readSearcedTodo(list: originalTodos, keyword: keyword)
                self.filteredTodos.value = Array(searchedTodos)
            } else {
                self.filteredTodos.value = []
            }
        }
        
    }
    
    private func removeFalseData(_ listCase: ReminderCase, idx: Int) {
        guard let todoList = self.originalTodoList.value else { return }
        let nowListName = todoList.listName
        // 현재 리스트가 깃발표시이고 업데이트 이후 데이터가 false 상태라면 테이블뷰 그리는 데이터에서 지워주기
        if nowListName == listCase.title {
            self.sortedOriginalTodos.value.remove(at: idx)
            self.inActivedSeachController.value = ()
        }
    }
}
