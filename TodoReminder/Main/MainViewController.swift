//
//  MainViewController.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit
import SnapKit

final class MainViewController: BaseViewControllerLargeTitle {
    private let vm = MainViewModel()
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .mainLayout())
    private let addButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: Resource.ImageCase.add.rawValue)
        configuration.title = Resource.ButtonTitle.addTodo.rawValue
        configuration.imagePadding = 4
        button.configuration = configuration
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        addObserver()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateList()
    }
    
    override func setupHierarchy() {
        view.addSubview(collectionView)
        view.addSubview(addButton)
    }
    
    override func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        addButton.snp.makeConstraints { make in
            make.leading.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        addButton.addTarget(self, action: #selector(addBtnTapped), for: .touchUpInside)
    }
    
    override func setupNavigation(_ title: String) {
        super.setupNavigation(ReminderCase.all.title)
    }
    
    override func configureRightBarButton(title: String?, imageName: String?, action: Selector?) {
        super.configureRightBarButton(title: nil, imageName: Resource.ImageCase.calendar.rawValue, action: #selector(calendarBtnTapped))
    }
    
    override func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: MainCollectionViewCell.identifier)
    }
    
    @objc func calendarBtnTapped(_ sender: UIButton) {
        let vc = CalendarViewController()
        transition(vc, type: .push)
    }
    
    @objc func addBtnTapped(_ sender: UIButton) {
        let vc = AddViewController(todoFromListVC: nil, viewType: .add)
        let navi = UINavigationController(rootViewController: vc)
        transition(navi, type: .present)
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDismissAddViewController), name: NSNotification.Name(Resource.NotificationCenterName.dismiss), object: nil)
    }
    
    // 뷰 업데이트 해야할 때 신호 보내기
    private func updateList() {
        vm.updateMainViewTrigger.value = ()
    }
    
    private func bind() {
        vm.inputLoadTodoList.value = ()
        
        // TodoList 모델로 저장된 데이터 Realm으로부터 받아오기
        vm.outputTodoList.bind { todoList in
            self.collectionView.reloadData()
        }
    }
    
    @objc func didDismissAddViewController(_ notification: Notification) {
        // AddVC 내려가면 MainVC 업데이트
        updateList()
    }
}

// MARK: CollectionViewExtension
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.outputTodoList.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionViewCell.identifier, for: indexPath) as! MainCollectionViewCell
        let todoList = vm.outputTodoList.value[indexPath.row]
        cell.configureCell(todoList)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let todoList = vm.outputTodoList.value[indexPath.row]
        let vc = ListViewController(todoList: todoList)
        transition(vc, type: .push)
    }
}
