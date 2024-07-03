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
        setupTableView()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupTableView() {
        
    }
    
    func setupCollectionView() {
        
    }
}
