//
//  CustomBorder.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/3/24.
//

import UIKit
import SnapKit

class CustomBorder: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureBorder()
    }
    
    private func configureBorder() {
        backgroundColor = .darkGray.withAlphaComponent(0.5)
        snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
