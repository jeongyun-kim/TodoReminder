//
//  ListViewController.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit
import RealmSwift
import SnapKit

class ListViewController: BaseViewControllerLargeTitle {
    private let realm = try! Realm()
    private let tableView = UITableView()
    var todoList: TodoList = TodoList(listCase: .all)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    }
    
    override func setupNavigation(_ title: String) {
        super.setupNavigation(todoList.listCase.title)
    }
    
    override func configureRightBarButton(title: String?, image: String?, action: Selector?) {
        super.configureRightBarButton(title: nil, image: Resource.ImageCase.more.rawValue, action: nil)
    }
    
    override func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.listCase.dbData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.identifier, for: indexPath) as! ListTableViewCell
        cell.configureCell(todoList.listCase.dbData[indexPath.row])
        return cell
    }
    
    // 오른쪽에서 왼쪽으로 밀었을 때 액션 나오게 
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "삭제") { [unowned self] _, _, _ in
            let data = self.todoList.listCase.dbData[indexPath.row]
            try! self.realm.write {
                self.realm.delete(data)
            }
            tableView.reloadData()
        }

       return UISwipeActionsConfiguration(actions: [delete])
    }
}
