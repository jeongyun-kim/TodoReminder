//
//  AddViewController.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit
import RealmSwift

final class AddViewController: BaseViewController {
    
    private let realm = try! Realm()
    private let tableView = UITableView()
    private var todoTitle: String = ""
    private var todoMemo: String = ""
    private var deadline: Date?
    private var tag: String?
    private var priority: String?
    private var priorityIdx: Int?
    private var attributeList: [String] = ["", "", "", "", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem?.isEnabled = false
        setupTableView()
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
        super.setupNavigation("새로운 할 일")
        let leftBarItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelBtnTapped))
        navigationItem.leftBarButtonItem = leftBarItem
    }
    
    override func configureRightBarButton(title: String?, image: String?, action: Selector?) {
        super.configureRightBarButton(title: "추가", image: nil, action: #selector(saveBtnTapped))
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: ContentTableViewCell.identifier)
        tableView.register(AttributeTableViewCell.self, forCellReuseIdentifier: AttributeTableViewCell.identifier)
    }
    
    @objc func saveBtnTapped(_ sender: UIButton) {
        // 저장할 데이터 생성
        let data = Todo(title: todoTitle, memo: todoMemo, deadline: deadline, tag: tag, priority: priority, savedate: Date(timeIntervalSinceNow: 32400))
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
            let vc = DateViewController(selectedDate: deadline)
            transition(vc, type: .push)
            vc.getDate = { date, dateString in
                self.deadline = date
                self.addAttributeAndReloadRow(dateString, indexPath: indexPath)
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
            vc.getPriority = { idx, title in
                self.priorityIdx = idx
                self.priority = title
                self.addAttributeAndReloadRow(title, indexPath: indexPath)
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
