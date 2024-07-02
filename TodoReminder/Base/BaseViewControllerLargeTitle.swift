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
        setupNavigation("")
    }
    
    override func setupNavigation(_ title: String) {
        super.setupNavigation(title)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
