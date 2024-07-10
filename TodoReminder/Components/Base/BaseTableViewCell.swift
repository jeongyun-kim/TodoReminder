//
//  BaseTableViewCell.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHierarchy()
        setupConstraints()
        configureLayout()
    }
    
    func setupHierarchy() {
        
    }
    
    func setupConstraints() {
        
    }
    
    func configureLayout() {
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

