//
//  AddViewModel.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/10/24.
//

import UIKit

final class AddViewModel {
    private let dateManager = DateFormatterManager.shared
    private let document = DocumentManager.shared
    private let repository = TodoRepository()
    
    // Input
    // ListVC로부터 받아오는 Todo 데이터
    var inputOriginalTodo: Observable<Todo?> = Observable(nil)
    // 테이블뷰 내 콘텐츠가 업데이트 될 때 사용되는 Input
    var updateTitle: Observable<String> = Observable("")
    var updateMemo: Observable<String?> = Observable("")
    var updateDeadline: Observable<Date?> = Observable(nil)
    var updateTag: Observable<String?> = Observable("")
    var updatePriorityIdx: Observable<Int?> = Observable(1)
    var updateImage: Observable<UIImage?> = Observable(nil)
    // 사용자 인터랙션에 대한 트리거
    var saveBtnTrigger: Observable<Resource.ViewType> = Observable(.add)
    var cancelBtnTrigger: Observable<Void?> = Observable(nil)
    
    // Output
    // AddVC에서 실질적으로 사용할 저장전 임시 Todo 데이터
    var outputTempTodo: Observable<Todo> = Observable(Todo())

    init() {
        print("AddVM init")
        configureOutputTempTodo()
        updateOutputTempTodo()
        outputTrigger()
    }
    
    deinit {
        print("AddVM deinit")
    }
    
    private func configureOutputTempTodo() {
        inputOriginalTodo.bind { [weak self] todo in
            if let todo { // 받아온 Todo 데이터가 있다면 해당 데이터로 임시 Todo 데이터 생성
                self?.configureNewTodo(title: todo.todoTitle, memo: todo.memo, deadline: todo.deadline, tag: todo.tag, priorityIdx: todo.priorityIdx, imageName: todo.imageName)
            } else { // 없다면 빈 임시 Todo 데이터 생성
                self?.outputTempTodo.value = Todo(title: "", savedate: Date())
            }
        }
    }
    
    private func updateOutputTempTodo() {
        // 테이블뷰를 reload 할 필요 없으므로 내부의 값 변경만
        updateTitle.bind { [weak self] title in
            self?.outputTempTodo.value.todoTitle = title
        }
        
        updateMemo.bind { [weak self] memo in
            self?.outputTempTodo.value.memo = memo
        }
        
        // 테이블뷰 reload위해 tempTodo 변경해주기
        updateDeadline.bind { [weak self] deadline in
            guard let deadline else { return }
            self?.configureNewTodo(deadline: deadline)
        }
        
        updateTag.bind { [weak self] tag in
            guard let tag else { return }
            self?.configureNewTodo(tag: tag)
        }
        
        updatePriorityIdx.bind { [weak self] idx in
            guard let idx else { return }
            self?.configureNewTodo(priorityIdx: idx)
        }
        
        // - configureNewTodo로 이미지 처리 시 새로운 id의 Todo 데이터가 생겨남
        //  - 그럼 이전 이미지의 이름과 새로 생겨난 이미지의 이름이 다르기 때문에 이전 이미지를 제거할 수 없음
        // 그래서 tempTodo의 이미지만 변경 -> tempTodo에 현재 tempTodo 넣어줘서 변경이 있었던 것처럼 처리 -> tableView.reload()
        updateImage.bind { [weak self] image in
            guard let image, let self else { return }
            let tempTodoId = self.outputTempTodo.value.id
            // 이미지 변경시마다 이전에 있던 이미지 지우기
            self.document.removeImageFromDocument(imageName: "\(tempTodoId)")
            // 셀에 이미지 보여주기 위해 Document에 이미지 저장
            self.document.saveImageToDocument(image: image, imageName: "\(tempTodoId)")
            // 셀에 이미지 정보가 있음을 알려주기 위해 imageName에 이미지명 넣어주기
            self.outputTempTodo.value.imageName = "\(tempTodoId)"
            self.outputTempTodo.value = self.outputTempTodo.value
        }
    }
    
    private func outputTrigger() {
        saveBtnTrigger.bind { [weak self] viewType in
            self?.saveTodo()
        }
        
        cancelBtnTrigger.bind { [weak self] _ in
            self?.cancel()
        }
    }
    
    // AddVC가 열릴 때 또는 할 일의 데이터를 편집할 때 변경된 데이터로 새로운 Todo 인스턴스를 만들어 outputTempTodo.value 변경해주기
    // -> AddVC에서는 자동으로 tableView.reload()
    private func configureNewTodo(title: String? = nil, memo: String? = nil, deadline: Date? = nil, tag: String? = nil, priorityIdx: Int? = nil, imageName: String? = nil) {
        let nowTodo = self.outputTempTodo.value
        
        let newTitle = title ?? nowTodo.todoTitle
        let newMemo = memo ?? nowTodo.memo
        let newDeadline = deadline ?? nowTodo.deadline
        let newTag = tag ?? nowTodo.tag
        let newPriorityIdx = priorityIdx ?? nowTodo.priorityIdx
        let newImageName = imageName ?? nowTodo.imageName
        
        let newTodo = Todo(title: newTitle, memo: newMemo, deadline: newDeadline, tag: newTag, priorityIdx: newPriorityIdx, imageName: newImageName, savedate: nowTodo.savedate)
        
        self.outputTempTodo.value = newTodo
    }
    
    // AddVC가 add모드냐 / edit모드냐에 따라 다르게 처리
    private func saveTodo() {
        let viewType = self.saveBtnTrigger.value
        
        switch viewType {
        case .add:
            let tempTodo = self.outputTempTodo.value
            tempTodo.savedate = self.dateManager.todayDate
            self.repository.createItem(tempTodo)
        case .edit:
            self.repository.updateTodo {
                guard let originalTodo = self.inputOriginalTodo.value else { return }
                let tempTodo = self.outputTempTodo.value
                originalTodo.todoTitle = tempTodo.todoTitle
                originalTodo.memo = tempTodo.memo
                originalTodo.deadline = tempTodo.deadline
                originalTodo.priorityIdx = tempTodo.priorityIdx
                originalTodo.tag = tempTodo.tag
                guard let postImageName = tempTodo.imageName else { return } // 변경된 상태의 이미지명 (아무런 이미지 선택도 안했으면 return)
                if let preImageName = originalTodo.imageName, preImageName != postImageName { // 이전에 이미지가 있었고 변경된 이미지 내역이 있다면
                    self.document.removeImageFromDocument(imageName: preImageName) // 이전의 이미지는 fileManager에서 제거
                }
                originalTodo.imageName = tempTodo.imageName // 그리고 변경된 이미지명 넣어주기
            }
        }
    }
    
    
    private func cancel() {
        // 변경된 이미지명 / 없으면 바로 return
        guard let tempImageName = self.outputTempTodo.value.imageName else { return  }
        // 이전의 이미지명 (없을수도 있고 있을수도 있음)
        let originalImageName = self.inputOriginalTodo.value?.imageName
        // 이전의 이미지명과 현재의 이미지명이 다른 상태(= 이미지 변경이 일어난 상태)
        if originalImageName != tempImageName {
            // 원본이미지를 보존하고 변경되면서 저장된 이후의 이미지 삭제
            self.document.removeImageFromDocument(imageName: tempImageName)
        }
    }
}
