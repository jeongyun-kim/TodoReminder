//
//  BaseViewControllerLargeTitle.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit

class BaseViewControllerLargeTitle: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation("", rightItemImage: "", action: nil)
        setupTableView()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func setupNavigation(_ title: String, rightItemTitle: String? = nil, rightItemImage: String? = nil, action: Selector?) {
        super.setupNavigation(title, rightItemTitle: rightItemTitle, rightItemImage: rightItemImage, action: action)
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    func setupTableView() {
        
    }
    
    func setupCollectionView() {
        
    }
}
