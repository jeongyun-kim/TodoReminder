//
//  BaseViewController.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupConstraints()
        setupUI()
        setupNavigation("")
        configureRightBarButton(title: "", imageName: "", action: nil)
        setupTableView()
        setupCollectionView()
    }
    
    func setupHierarchy() {
        
    }
    
    func setupConstraints() {
        
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
    }
    
    func setupNavigation(_ title: String) {
        navigationItem.title = title
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func configureRightBarButton(title: String?, imageName: String?, action: Selector?) {
        var rightItem: UIBarButtonItem
        if let title = title {
            rightItem = UIBarButtonItem(title: title, style: .plain, target: self, action: action)
        } else {
            guard let image = imageName else { return }
            rightItem = UIBarButtonItem(image: UIImage(systemName: image), style: .plain, target: self, action: action)
        }
        navigationItem.rightBarButtonItem = rightItem
    }
    
    func setupTableView() { }
    
    func setupCollectionView() { }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
