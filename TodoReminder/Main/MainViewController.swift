//
//  MainViewController.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit
import SnapKit
import RealmSwift

final class MainViewController: BaseViewControllerLargeTitle {
    private lazy var list = TodoList.list {
        didSet {
            collectionView.reloadData()
        }
    }
    private let realm = try! Realm()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    private let addButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: Resource.ImageCase.add.rawValue)
        configuration.title = "새로운 할 일"
        configuration.imagePadding = 4
        button.configuration = configuration
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        addObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        list = TodoList.list
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
        super.setupNavigation("전체")
    }
    
    private func layout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 8
        let inset: CGFloat = 16
        let width = (UIScreen.main.bounds.width - spacing - inset*2) / 2
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        layout.itemSize = CGSize(width: width, height: width*0.45)
        return layout
    }
    
    override func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: MainCollectionViewCell.identifier)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDismissAddViewController), name: NSNotification.Name(Resource.NotificationCenterName.dismiss), object: nil)
    }
    
    @objc func addBtnTapped(_ sender: UIButton) {
        let vc = AddViewController()
        let navi = UINavigationController(rootViewController: vc)
        transition(navi, type: .present)
    }
    
    @objc func didDismissAddViewController(_ notification: Notification) {
        DispatchQueue.main.async {
            self.list = TodoList.list
        }
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ReminderCase.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionViewCell.identifier, for: indexPath) as! MainCollectionViewCell
        cell.configureCell(list[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ListViewController()
        vc.todoList = list[indexPath.row]
        transition(vc, type: .push)
    }
}
