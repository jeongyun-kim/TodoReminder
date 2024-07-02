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
        setupNavigation("", rightItemImage: "", action: nil)
    }
    
    func setupHierarchy() {
        
    }
    
    func setupConstraints() {
        
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
    }
    
    func setupNavigation(_ title: String, rightItemImage: String, action: Selector?) {
        navigationItem.title = title
        let rightItem = UIBarButtonItem(image: UIImage(systemName: rightItemImage), style: .plain, target: self, action: action)
        navigationItem.rightBarButtonItem = rightItem
    }
}
