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
    private var originalList: [Todo] = []
    var filterType: ReminderCase = .all
    
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        setupSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        list = repository.readFilteredItem(filterType)
        originalList = list
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
    
    override func configureRightBarButton(title: String?, imageName: String?, action: Selector?) {
        let asc = UIAction(title: "오래된 순", handler: { _ in
            self.list = self.repository.readFilteredItem(self.filterType)
            self.originalList = self.list
        })
        let desc = UIAction(title: "최신순", handler: { _ in
            self.list = self.repository.readFilteredItem(self.filterType, sort: .dateDesc)
            self.originalList = self.list
        })
        let menu = UIMenu(children: [asc, desc])
        let filter = UIBarButtonItem(title: nil, image: UIImage(systemName: Resource.ImageCase.more.rawValue), primaryAction: nil, menu: menu)
        //filter.changesSelectionAsPrimaryAction = true // more 이미지가 왜 제목으로 바뀌는지..?
        navigationItem.rightBarButtonItem = filter
    }
    
    override func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
    }
    
    private func setupSearchController() {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "검색어를 입력해주세요" // 검색어 입력칸에 안내 문구
        searchController.searchBar.autocapitalizationType = .none // 영어 첫글자 대문자 X
        searchController.hidesNavigationBarDuringPresentation = true // 검색하는동안 네비게이션 숨길지
        self.navigationItem.hidesSearchBarWhenScrolling = false // 스크롤 하는동안 서치바 숨길지(기본적으로 vc에 들어왔을 때, 서치바가 보이게하려면 false)
        self.navigationItem.searchController = searchController // navigationItem에 searchController 등록
        searchController.searchResultsUpdater = self // 실시간 검색을 위한 delegate 연결
    }
    
    @objc public func completeBtnTapped(_ sender: UIButton) {
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
            self.list = self.originalList
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
        cell.completeButton.addTarget(self, action: #selector(completeBtnTapped), for: .touchUpInside)
        return cell
    }
    
    // 오른쪽에서 왼쪽으로 밀었을 때 액션 나오게 
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 삭제
        let delete = UIContextualAction(style: .destructive, title: "삭제") { [unowned self] _, _, _ in
            let data = self.list[indexPath.row]
            if let imageName = data.imageName {
                view.removeImageFromDocument(imageName: imageName)
            }
            repository.deleteItem(data.id)
            list = repository.readFilteredItem(filterType)
        }
       return UISwipeActionsConfiguration(actions: [delete])
    }
    
    // 왼쪽에서 오른쪽으로 밀었을 때 액션 
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 깃발 표시
        let flag = UIContextualAction(style: .normal, title: ReminderCase.flag.title) { [unowned self] _, _, _ in
            let data = self.list[indexPath.row]
            repository.updateItem {
                data.isFlag.toggle()
                list = repository.readFilteredItem(filterType)
            }
        }
        flag.backgroundColor = ReminderCase.flag.imageColor
        
        let bookmark = UIContextualAction(style: .normal, title: ReminderCase.bookmark.title) { [unowned self] _, _, _ in
            let data = self.list[indexPath.row]
            repository.updateItem {
                data.isBookmark.toggle()
                list = repository.readFilteredItem(filterType)
            }
        }
        bookmark.backgroundColor = ReminderCase.bookmark.imageColor
        return UISwipeActionsConfiguration(actions: [flag, bookmark])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = list[indexPath.row]
        let vc = AddViewController(todoFromListVC: data, viewType: .edit)
        let navi = UINavigationController(rootViewController: vc)
        transition(navi, type: .present)
    }
}

extension ListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // 검색한 결과에서 어떤 아이템을 편집하고 돌아오면 NotificationCenter의 Observer때문에 모든 리스트가 나오게 됨
        // 그러므로 검색하는 동안에는 옵저버 제거하기
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Resource.NotificationCenterName.dismiss), object: nil)
        
        // 서치바가 Active 상태라면
        if searchController.isActive {
            // 서치바에 키워드가 있는지
            // - 키워드가 있다면 현재 리스트에 찐리스트에서 키워드로 검색한 결과 넣어주기
            // - 키워드가 비어있다면 아무런 결과 보여주지않게 현재 리스트에 빈 배열 넣어주기
            guard let keyword = searchController.searchBar.text, !keyword.isEmpty else { return list = [] }
            list = repository.readSearchedItem(list: originalList, keyword: keyword)
        } else { // 서치바가 InActive 상태라면 (= cancel 눌러서 서치바 비활성화 상태로 만들었을 때)
            list = originalList // 원래 보여주고 있던 데이터 보여주기
            addObserver() // 옵저버 다시 등록하기
        }
    }
}
