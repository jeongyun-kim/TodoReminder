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
    }
    
    override func setupNavigation(_ title: String, rightItemImage: String, action: Selector?) {
        super.setupNavigation(title, rightItemImage: rightItemImage, action: action)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
