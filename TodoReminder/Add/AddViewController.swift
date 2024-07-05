//
//  AddViewController.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit
import PhotosUI

final class AddViewController: BaseViewController {
    init(todoFromListVC: Todo?, viewType: Resource.ViewType) {
        super.init(nibName: nil, bundle: nil)
        self.todoFromListVC = todoFromListVC
        self.viewType = viewType
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var todoFromListVC: Todo?
    private var tempTodo: Todo = Todo(title: "", memo: nil, deadline: nil, tag: nil, priorityIdx: nil, imageName: nil, savedate: Date())
    private let repository = TodoRepository()
    var viewType: Resource.ViewType = .add
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        // 만약 ListVC에서 AddVC로 넘어올 때, tempTodo = todoFromListVC를 해주면 결국 tempTodo가 realm내 저장되어있는 데이터를 가리키게 됨
        // 그럼 속성을 수정한다면 realm.try! 구문외에서 데이터를 업데이트하려는 행위가 되기 때문에 에러가 발생함
        // 그러므로 ListVC에서 받아온 데이터의 값만 넣어서 tempTodo를 구성해줘야 함
        if let data = todoFromListVC {
            tempTodo = Todo(title: data.title, memo: data.memo, deadline: data.deadline, tag: data.tag, priorityIdx: data.priorityIdx, imageName: data.imageName, savedate: data.savedate)
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // modal이 내려갈 때 NotificationCenter에 알림보내기 
        NotificationCenter.default.post(name: NSNotification.Name(Resource.NotificationCenterName.dismiss), object: nil, userInfo: nil)
    }
    
    override func setupHierarchy() {
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        tableView.separatorStyle = .none
    }
    
    override func setupNavigation(_ title: String) {
        super.setupNavigation(viewType.rawValue)
        let leftBarItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelBtnTapped))
        navigationItem.leftBarButtonItem = leftBarItem
    }
    
    override func configureRightBarButton(title: String?, image: String?, action: Selector?) {
        super.configureRightBarButton(title: viewType.rightBarTitle, image: nil, action: #selector(saveBtnTapped))
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: ContentTableViewCell.identifier)
        tableView.register(AttributeTableViewCell.self, forCellReuseIdentifier: AttributeTableViewCell.identifier)
    }
    
    @objc func saveBtnTapped(_ sender: UIButton) {
        switch viewType {
        // Main -> Add : 데이터 추가
        case .add:
            // 현재 저장시기 시차 +9 적용
            tempTodo.savedate = Date(timeIntervalSinceNow: 32400)
            repository.createItem(tempTodo)
        // List -> Add : 데이터 변경
        case .edit:
            repository.updateItem {
                guard let todoFromListVC else { return }
                todoFromListVC.title = tempTodo.title
                todoFromListVC.memo = tempTodo.memo
                todoFromListVC.deadline = tempTodo.deadline
                todoFromListVC.priorityIdx = tempTodo.priorityIdx
                todoFromListVC.tag = tempTodo.tag
                guard let postImageName = tempTodo.imageName else { return } // 변경된 상태의 이미지명 (아무런 이미지 선택도 안했으면 return)
                if let preImageName = todoFromListVC.imageName, preImageName != postImageName { // 이전에 이미지가 있었고 변경된 이미지 내역이 있다면
                    view.removeImageFromDocument(imageName: preImageName) // 이전의 이미지는 fileManager에서 제거
                }
                todoFromListVC.imageName = tempTodo.imageName // 그리고 변경된 이미지명 넣어주기
            }
        }
        dismiss(animated: true)
    }
    
    @objc func cancelBtnTapped(_ sender: UIButton) {
        // 변경된 이미지가 없다면 dismiss
        guard let tempImageName = tempTodo.imageName else { return dismiss(animated: true) }
        // 이전의 이미지명 (없을수도 있고 있을수도 있음)
        let originalImageName = todoFromListVC?.imageName
        // 이전의 이미지명과 현재의 이미지명이 다른 상태(= 이미지 변경이 일어난 상태)
            if originalImageName != tempImageName {
            // 원본이미지를 보존하고 변경되면서 저장된 이후의 이미지 삭제
            view.removeImageFromDocument(imageName: tempImageName)
        }
        dismiss(animated: true)
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        guard let text = sender.text else { return }
        tempTodo.title = text
        if text.isEmpty || text.components(separatedBy: " ").joined().count == 0 {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    private func reloadCell(_ indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}

// MARK: TableViewDelegate
extension AddViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 210 : 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Resource.AddAttributeCase.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ContentTableViewCell.identifier, for: indexPath) as! ContentTableViewCell
            cell.memoTextView.delegate = self
            cell.titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            cell.configureCell(tempTodo)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AttributeTableViewCell.identifier, for: indexPath) as! AttributeTableViewCell
            cell.configureCell(Resource.AddAttributeCase.allCases[indexPath.row], data: tempTodo)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            let vc = DateViewController(deadline: tempTodo.deadline)
            transition(vc, type: .push)
            vc.getDate = { deadline in
                self.tempTodo.deadline = deadline
                self.reloadCell(indexPath)
            }
       case 2:
            let vc = TagViewController(tag: tempTodo.tag)
            transition(vc, type: .push)
            vc.getTag = { tag in
                self.tempTodo.tag = tag
                self.reloadCell(indexPath)
            }
        case 3:
            let vc = PriorityViewController(selectedIdx: tempTodo.priorityIdx)
            transition(vc, type: .push)
            vc.getPriorityIdx = { idx in
                self.tempTodo.priorityIdx = idx
                self.reloadCell(indexPath)
            }
        case 4:
            var config = PHPickerConfiguration()
            config.filter = .images
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            transition(picker, type: .push)
        default: break
        }
    }
}

// MARK: TextViewDelegate
extension AddViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor != .white {
            textView.text = ""
            textView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = textView.text else { return }
        if text.isEmpty {
            textView.text = "메모"
            textView.textColor = .systemGray2
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        tempTodo.memo = text
    }
}

// MARK: PHPickerDelegate
extension AddViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // itemProvider : 선택한 이미지와 관련된 데이터 정보들
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            // 여기는 mainThread
            itemProvider.loadObject(ofClass: UIImage.self) { [unowned self] image, error in
                // 이 코드 구문은 애플에서 global에서 처리하도록 해둬서 이미지를 대입해주는건 main으로 넘겨줘야함
                DispatchQueue.main.async {
                    // 이미지 변경시마다 이전에 있던 이미지 지우기
                    self.view.removeImageFromDocument(imageName: "\(self.tempTodo.id)")
                    // image가 NSItemProviderReading이라는 데이터 타입이기 때문에 UIImage로 변환할 수 있는지 확인
                    guard let convertedImage = image as? UIImage else { return }
                    // 셀에 이미지 보여주기 위해 Document에 이미지 저장
                    self.view.saveImageToDocument(image: convertedImage, imageName: "\(self.tempTodo.id)")
                    // 셀에 이미지 정보가 있음을 알려주기 위해 imageName에 이미지명 넣어주기
                    self.tempTodo.imageName = "\(self.tempTodo.id)"
                    // 이미지 속성셀 reload
                    self.reloadCell(IndexPath(row: 4, section: 0))
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
}
