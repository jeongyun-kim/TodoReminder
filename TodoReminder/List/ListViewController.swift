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
    init(todoList: TodoList) {
        super.init(nibName: nil, bundle: nil)
        print("ListVC init")
        self.vm.originalTodoList.value = todoList
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("ListVC deinit")
    }
    
    let vm = ListViewModel()
    
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        setupSearchController()
        bind()
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
        guard let originalTodoList = vm.originalTodoList.value else { return }
        let listName = originalTodoList.title
        super.setupNavigation(listName)
    }
    
    override func configureRightBarButton(title: String?, imageName: String?, action: Selector?) {
        let asc = UIAction(title: "오래된 순", handler: { [weak self] _ in
            self?.vm.sortTodosTrigger.value = true
        })
        let desc = UIAction(title: "최신순", handler: { [weak self] _ in
            self?.vm.sortTodosTrigger.value = false
        })
        let menu = UIMenu(children: [asc, desc])
        let filter = UIBarButtonItem(title: nil, image: UIImage(systemName: Resource.ImageCase.more.rawValue), primaryAction: nil, menu: menu)
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
        searchController.hidesNavigationBarDuringPresentation = false // 검색하는동안 네비게이션 숨길지
        self.navigationItem.hidesSearchBarWhenScrolling = false // 스크롤 하는동안 서치바 숨길지(기본적으로 vc에 들어왔을 때, 서치바가 보이게하려면 false)
        self.navigationItem.searchController = searchController // navigationItem에 searchController 등록
        searchController.searchResultsUpdater = self // 실시간 검색을 위한 delegate 연결
        searchController.searchBar.delegate = self
    }
    
    @objc private func completeBtnTapped(_ sender: UIButton) {
        vm.completeTrigger.value = sender.tag
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDismissAddViewController), name: NSNotification.Name(Resource.NotificationCenterName.dismiss), object: nil)
    }
    
    @objc private func didDismissAddViewController(_ notification: Notification) {
        // 검색 상태에서 편집 시 현재 검색 중이던 키워드로 다시 테이블뷰 그리기
        // 아니면 그냥 테이블뷰 업데이트
        fetchSearchResult()
    }
    
    private func fetchSearchResult() {
        // 서치바가 활성화 상태라면
        // - 키워드가 있다면 현재 목록 내 투두리스트의 제목/메모에 키워드가 포함된 결과 가져와 list에 반영해주기
        // - 키워드가 비어있다면 아무런 결과 보여주지않게 현재 리스트에 빈 배열 넣어주기
        if searchController.isActive {
            vm.searchTrigger.value = searchController.searchBar.text
        } else { // 비활성화 상태라면 테이블뷰 다시 그리기
            vm.inActivatedSearchController.value = ()
        }
    }
    
    private func bind() {
        // 데이터 자체에 변동사항이 생겼을 때 ex) 정렬, 삭제 
        vm.outputTodos.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
        
        // 할 일 즐겨찾기 / 깃발표시 / 완료했을 때
        vm.updatedTodoStatus.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
}

// MARK: TableViewExtension
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.outputTodos.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.identifier, for: indexPath) as! ListTableViewCell
        let todo = vm.outputTodos.value[indexPath.row]
        cell.configureCell(todo)
        cell.completeButton.tag = indexPath.row
        cell.completeButton.addTarget(self, action: #selector(completeBtnTapped), for: .touchUpInside)
        return cell
    }
    
    // 오른쪽에서 왼쪽으로 밀었을 때 액션 나오게 
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 삭제
        let delete = UIContextualAction(style: .destructive, title: "삭제") { [unowned self] _, _, _ in
            vm.deleteTodoTrigger.value = indexPath.row
            // 할 일 삭제했을 때, 검색중이었는지 아니었는지에 따라 처리
            fetchSearchResult()
        }
       return UISwipeActionsConfiguration(actions: [delete])
    }

    // 왼쪽에서 오른쪽으로 밀었을 때 액션
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let idx = indexPath.row
        // 깃발 표시
        let flag = UIContextualAction(style: .normal, title: ReminderCase.flag.title) { [unowned self] _, _, _ in
            vm.flagTrigger.value = idx
        }
        flag.backgroundColor = UIColor(hexCode: ReminderCase.flag.imageColor)
        let bookmark = UIContextualAction(style: .normal, title: ReminderCase.bookmark.title) { [unowned self] _, _, _ in
            vm.bookmarkTrigger.value = idx
        }
        bookmark.backgroundColor = UIColor(hexCode: ReminderCase.bookmark.imageColor)
        return UISwipeActionsConfiguration(actions: [flag, bookmark])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = vm.outputTodos.value[indexPath.row]
        let vc = AddViewController(todoFromListVC: data, viewType: .edit)
        let navi = UINavigationController(rootViewController: vc)
        transition(navi, type: .present)
    }
}

// MARK: SearchResultsUpdating
extension ListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        fetchSearchResult()
    }
}
