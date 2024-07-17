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
    // 검색 시작 시
    var searchTrigger: Observable<String?> = Observable("")
    // 검색 끝나고 다시 데이터 넣어줘야할 때
    var inActivatedSearchController: Observable<Void?> = Observable(nil)
    // 할 일 완료
    var completeTrigger: Observable<Int> = Observable(0)
    // 깃발 표시
    var flagTrigger: Observable<Int> = Observable(0)
    // 즐겨찾기 표시
    var bookmarkTrigger: Observable<Int> = Observable(0)
    // 정렬
    var sortTodosTrigger: Observable<Bool> = Observable(false)
    // 할 일 삭제
    var deleteTodoTrigger: Observable<Int> = Observable(0)
    
    // Output
    // 원본의 할 일 목록을 정렬해 검색이 끝났을 때, 정렬이 유지된 채로 할 일들이 다시 그려지기 위해 사용
    // -> VC에서 실질적인 사용은 X
    var sortedOriginalTodos: Observable<[Todo]> = Observable([])
    // 정렬, 검색 결과 등을 담아 실질적으로 테이블뷰를 그리는데 사용되는 할 일 목록
    var outputTodos: Observable<[Todo]> = Observable([])
    // idx: reload할 cell의 순번 -> VC에서 cell reload
    var updatedTodoStatus: Observable<Int> = Observable(0)
    
    init() { 
        print("ListVM init")
        transform()
    }
    
    deinit {
        print("ListVM deinit")
    }
    
    private func transform() {
        inputOriginalTodoLists()
        updateTodoData()
        searchTriggers()
        
        sortTodosTrigger.bind { [weak self] ascType in
            guard let self else { return }
            guard let originalTodoList = self.originalTodoList.value else { return }
            let originalTodos = originalTodoList.todos
            let sortedTodos = self.repository.readSortedTodo(originalTodos, ascending: ascType)
            self.sortedOriginalTodos.value = sortedTodos
            self.outputTodos.value = sortedTodos
        }
        
        deleteTodoTrigger.bind { [weak self] idx in
            guard let self else { return }
            let todoToDelete = self.outputTodos.value[idx]
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
    
    // 원본 할 일 목록이 업데이트 될 때
    private func inputOriginalTodoLists() {
        originalTodoList.bind { [weak self] todoList in
            guard let originalTodoList = todoList else { return }
            let originalTodos = originalTodoList.todos
            // 원본 데이터로 ListVC에서 그려주기
            self?.outputTodos.value = Array(originalTodos)
            // 현재 정렬 상태로 원본 데이터 저장
            self?.sortedOriginalTodos.value = Array(originalTodos)
        }
    }

    // 할 일이 업데이트 될 때 ex) 완료, 즐겨찾기, 깃발
    private func updateTodoData() {
        // 할 일 완료 처리 -> VC에서는 해당 idx의 셀만 reload
        // 만약 완료됨 리스트뷰인데, 완료됨을 해제했다면? -> 테이블뷰 그려주는 리스트에서 해당 데이터 제거
        completeTrigger.bind { [weak self] idx in
            guard let self else { return }
            
            let data = self.outputTodos.value[idx]
            
            self.repository.updateTodo {
                data.isComplete.toggle()
            }
            
            if !data.isComplete {
                self.removeFalseData(.complete, idx: idx)
            }
            self.updatedTodoStatus.value = idx
        }
        
        bookmarkTrigger.bind { [weak self] idx in
            guard let self else { return }
            
            let data = self.outputTodos.value[idx]
       
            self.repository.updateTodo {
                data.isBookmark.toggle()
            }

            if !data.isBookmark {
                self.removeFalseData(.bookmark, idx: idx)
            }
            self.updatedTodoStatus.value = idx
        }
        
        flagTrigger.bind { [weak self] idx in
            guard let self else { return }
            
            let data = self.outputTodos.value[idx]
            
            self.repository.updateTodo {
                data.isFlag.toggle()
            }
            
            if !data.isFlag {
                self.removeFalseData(.flag, idx: idx)
            }
            self.updatedTodoStatus.value = idx
        }
    }
    
    // 검색 / 검색 안 할 때
    private func searchTriggers() {
        // 검색 취소 버튼 눌렀을 때, 이전의 테이블뷰 다시 그려주기 위해
        inActivatedSearchController.bind { [weak self] _ in
            guard let self else { return }
            
            let sortedTodos = self.sortedOriginalTodos.value
            // 정렬되어있던 찐리스트 넣어주기
            self.outputTodos.value = sortedTodos
        }
        
        // 검색 처리
        searchTrigger.bind { [weak self] keyword in
            guard let originalTodoList = self?.originalTodoList.value else { return }
            let originalTodos = originalTodoList.todos
            
            // 서치바에 키워드가 있다면
            if let keyword, !keyword.isEmpty {
                // 검색해서 결과 보여주기
                guard let searchedTodos = self?.repository.readSearcedTodo(list: originalTodos, keyword: keyword) else { return }
                self?.outputTodos.value = Array(searchedTodos)
            } else { // 없다면 빈 데이터 보여주기
                self?.outputTodos.value = []
            }
        }
    }
    
    private func removeFalseData(_ listCase: ReminderCase, idx: Int) {
        guard let todoList = self.originalTodoList.value else { return }
        let nowListName = todoList.title
        // 현재 리스트가 깃발표시이고 업데이트 이후 데이터가 false 상태라면 테이블뷰 그리는 데이터에서 지워주기
        if nowListName == listCase.title {
            self.sortedOriginalTodos.value.remove(at: idx)
            // 데이터 업데이트
            self.inActivatedSearchController.value = ()
        }
    }
}
