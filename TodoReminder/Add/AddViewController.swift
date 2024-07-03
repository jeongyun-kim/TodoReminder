//
//  AddViewController.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit
import RealmSwift

final class AddViewController: BaseViewController {
    init(todoData: Todo?, viewType: Resource.ViewType) {
        super.init(nibName: nil, bundle: nil)
        self.todoData = todoData
        self.viewType = viewType
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var todoData: Todo?
    private let realm = try! Realm()
    var viewType: Resource.ViewType = .add
    
    private let tableView = UITableView()
    private var todoTitle: String = ""
    private var todoMemo: String = ""
    private var deadline: String?
    private var cellDeadline: String?
    private var tag: String?
    private var priority: String?
    private var priorityIdx: Int?
    // 1. 마감일 - 2. 태그 - 3. 우선순위 - 4. 이미지 추가
    private var attributeList: [String] = ["", "", "", "", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem?.isEnabled = false
        setupTableView()
        if let todoData {
            navigationItem.rightBarButtonItem?.isEnabled = true
            todoTitle = todoData.title
            if let memo = todoData.memo {
                todoMemo = memo
            }
            if let tempDeadline = todoData.deadline {
                deadline = tempDeadline
                attributeList[1] = tempDeadline
            }
            if let tempTag = todoData.tag {
                tag = tempTag
                attributeList[2] = tempTag
            }
            if let tempPriorityIdx = todoData.priorityIdx {
                priorityIdx = tempPriorityIdx
                attributeList[3] = Resource.PrioritySegmentTitleCase.allCases[tempPriorityIdx].rawValue
            }
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
        // 현재 저장시기 시차 +9 적용
        let savedate = Date(timeIntervalSinceNow: 32400)
        // 저장할 데이터 생성
        let data = Todo(title: todoTitle, memo: todoMemo, deadline: deadline, tag: tag, priorityIdx: priorityIdx, savedate: savedate)
        // 데이터 저장
        try! realm.write {
            realm.add(data)
        }
        dismiss(animated: true)
    }
    
    @objc func cancelBtnTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        guard let text = sender.text else { return }
        todoTitle = text
        if text.isEmpty || text.components(separatedBy: " ").joined().count == 0 {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }

    private func addAttributeAndReloadRow(_ data: String, indexPath: IndexPath) {
        attributeList[indexPath.row] = data
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .none)
        }
    }
}


extension AddViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 210
        } else {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AddAttributeCase.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ContentTableViewCell.identifier, for: indexPath) as! ContentTableViewCell
            cell.memoTextView.delegate = self
            cell.titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            guard let todoData else { return cell }
            cell.configureCell(todoData)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AttributeTableViewCell.identifier, for: indexPath) as! AttributeTableViewCell
            cell.configureCell(AddAttributeCase.allCases[indexPath.row].rawValue, attribute: attributeList[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            let vc = DateViewController(dateString: deadline)
            transition(vc, type: .push)
            vc.getDate = { deadlineString in
                self.deadline = deadlineString
                self.addAttributeAndReloadRow(deadlineString, indexPath: indexPath)
            }
       case 2:
            let vc = TagViewController(tag: tag)
            transition(vc, type: .push)
            vc.getTag = { tag in
                self.tag = tag
                self.addAttributeAndReloadRow(tag, indexPath: indexPath)
            }
        case 3:
            let vc = PriorityViewController(selectedIdx: priorityIdx)
            transition(vc, type: .push)
            vc.getPriority = { idx in
                self.priorityIdx = idx
                let cellString = Resource.PrioritySegmentTitleCase.allCases[idx].rawValue
                self.addAttributeAndReloadRow(cellString, indexPath: indexPath)
            }
//        case 4:
        default: break
        }
    }
}

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
        todoMemo = text
    }
}
