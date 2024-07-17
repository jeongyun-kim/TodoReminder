//
//  MainViewModel.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/10/24.
//

import Foundation

final class MainViewModel {
    private let repository = TodoListRepository()
    
    // Input
    // MainVC의 컬렉션뷰 데이터를 다시 받아와야할 때 사용하는 신호
    var inputLoadTodoList: Observable<Void?> = Observable(nil)
    // MainVCd의 컬렉션뷰 데이터를 업데이트해줘야할 때
    var updateMainViewTrigger: Observable<Void?> = Observable(nil)
    
    // Output
    // realm으로부터 받아온 TodoList 모델의 데이터들
    var outputTodoList: Observable<[TodoList]> = Observable([])
    
    init() {
        print("MainVM init")
        transform()
    }
    
    deinit {
        print("MainVM deinit")
    }
    
    private func transform() {
        // 뷰가 불러와졌을 때 또는 업데이트 이후에 새로 리스트를 받아오게
        inputLoadTodoList.bind { [weak self] _ in
            guard let self else { return }
            self.outputTodoList.value = self.repository.readAll()
        }
        
        // 할 일이 새로 생겼거나 지워졌을 때 업데이트
        updateMainViewTrigger.bind { [weak self] _ in
            guard let self else { return }
            
            for todoList in self.outputTodoList.value {
                let newToDoList = TodoRepository().readFilteredTodo(todoList.title)
                self.repository.updateList(todoList, list: newToDoList)
                // 업데이트 이후 '새로운 데이터 받아와줘'하고 신호 보내기
                self.inputLoadTodoList.value = ()
            }
        }
    }
}
