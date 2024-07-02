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
    private var list: Results<Todo>! { // IUO
        didSet {
            tableView.reloadData()
        }
    }
    var navigationTitle: String = "전체"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        list = realm.objects(Todo.self)
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
    
    
    override func setupNavigation(_ title: String, rightItemTitle: String?, rightItemImage: String?, action: Selector?) {
        super.setupNavigation(navigationTitle, rightItemTitle: nil, rightItemImage: "plus", action: #selector(addBtnTapped))
    }
    
    override func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
    }
    
    @objc func addBtnTapped(_ sender: UIButton) {
        let vc = AddViewController()
        //let navi = UINavigationController(rootViewController: vc)
        transition(vc, type: .push)
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.identifier, for: indexPath) as! ListTableViewCell
        cell.configureCell(list[indexPath.row])
        return cell
    }
}
