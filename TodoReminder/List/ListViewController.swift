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
    init(filterType: ReminderCase) {
        super.init(nibName: nil, bundle: nil)
        self.filterType = filterType
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let repository = TodoRepository()
    private var list: [Todo] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var filterType: ReminderCase = .all
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        list = repository.readFilteredItem(filterType)
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
        super.setupNavigation(filterType.title)
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
    
    @objc func checkBtnTapped(_ sender: UIButton) {
        repository.updateItem {
            list[sender.tag].isComplete.toggle()
            tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
        }
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDismissAddViewController), name: NSNotification.Name(Resource.NotificationCenterName.dismiss), object: nil)
    }
    
    @objc func didDismissAddViewController(_ notification: Notification) {
        DispatchQueue.main.async {
            self.list = self.repository.readFilteredItem(self.filterType)
        }
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.identifier, for: indexPath) as! ListTableViewCell
        cell.configureCell(list[indexPath.row])
        cell.completeButton.tag = indexPath.row
        cell.completeButton.addTarget(self, action: #selector(checkBtnTapped), for: .touchUpInside)
        return cell
    }
    
    // 오른쪽에서 왼쪽으로 밀었을 때 액션 나오게 
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "삭제") { [unowned self] _, _, _ in
            let data = self.list[indexPath.row]
            repository.deleteItem(data.id)
            list = repository.readFilteredItem(filterType)
        }
       return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = list[indexPath.row]
        let vc = AddViewController(todoFromListVC: data, viewType: .edit)
        let navi = UINavigationController(rootViewController: vc)
        transition(navi, type: .present)
    }
}
