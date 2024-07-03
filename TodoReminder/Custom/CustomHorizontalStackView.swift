//
//  CustomStackView.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/3/24.
//

import UIKit

class CustomHorizontalStackView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureStackView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureStackView() {
        axis = .horizontal
        spacing = 4
    }
}
