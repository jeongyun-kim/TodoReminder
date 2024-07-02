//
//  AddViewController.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit
import RealmSwift

enum AttributeTitleCase: String, CaseIterable {
    case deadline = "마감일"
    case tag  = "태그"
    case priority = "우선순위"
    case addImage = "이미지 추가"
}

final class AddViewController: BaseViewController {
    
    private let realm = try! Realm()
    private let tableView = UITableView()
    private var todoTitle: String = ""
    private var todoMemo: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem?.isEnabled = false
        setupTableView()
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
    
    override func setupNavigation(_ title: String, rightItemTitle: String?, rightItemImage: String?, action: Selector?) {
        super.setupNavigation("새로운 할 일", rightItemTitle: "추가", rightItemImage: nil, action: #selector(saveBtnTapped))
        let leftBarItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelBtnTapped))
        navigationItem.leftBarButtonItem = leftBarItem
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: ContentTableViewCell.identifier)
        tableView.register(AttributeTableViewCell.self, forCellReuseIdentifier: AttributeTableViewCell.identifier)
    }
    
    @objc func saveBtnTapped(_ sender: UIButton) {
        // 저장할 데이터 생성
        let data = Todo(title: todoTitle, content: todoMemo, savedate: Date())
        // 데이터 저장
        try! realm.write {
            realm.add(data)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc func cancelBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        guard let text = sender.text else { return }
        todoTitle = text
        if text.isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ContentTableViewCell.identifier, for: indexPath) as! ContentTableViewCell
            cell.memoTextView.delegate = self
            cell.titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AttributeTableViewCell.identifier, for: indexPath) as! AttributeTableViewCell
            cell.configureCell(AttributeTitleCase.allCases[indexPath.row-1].rawValue)
            return cell
        }
    }
}

extension AddViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard let text = textView.text else { return }
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
        } else {
            todoMemo = text
        }
    }
}
