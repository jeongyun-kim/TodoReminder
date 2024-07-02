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
    
    private let realm = try! Realm()
    private lazy var list: [String] = configureList() {
        didSet {
            collectionView.reloadData()
        }
    }
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func setupHierarchy() {
        view.addSubview(collectionView)
    }
    
    override func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
    }
    
    override func setupNavigation(_ title: String, rightItemImage: String, action: Selector?) {
        super.setupNavigation("전체", rightItemImage: "plus", action: #selector(addBtnTapped))
    }
    
    @objc func addBtnTapped(_ sender: UIButton) {
        print(#function)
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
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: MainCollectionViewCell.identifier)
    }
    
    private func configureList() -> [String] {
        let allData = realm.objects(Todo.self)
        let todayData = allData.where { $0.deadline == Date() }
        let scheduleData = allData.where { $0.deadline != nil && $0.deadline != Date() }
        let flagData = allData.where { $0.isFlag }
        let dataList = ["\(todayData.count)", "\(scheduleData.count)", "\(allData.count)", "\(flagData.count)", ""]
        return dataList
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ReminderCase.allCases.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionViewCell.identifier, for: indexPath) as! MainCollectionViewCell
        cell.configureCell(ReminderCase.allCases[indexPath.row], list[indexPath.row])
        return cell
    }
}
