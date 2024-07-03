//
//  ContentTableViewCell.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit
import SnapKit

class ContentTableViewCell: BaseTableViewCell {
    private let bgView = UIView()
    let titleTextField = UITextField()
    private let border = CustomBorder()
    let memoTextView = UITextView()
    
    override func setupHierarchy() {
        contentView.addSubview(bgView)
        bgView.addSubview(titleTextField)
        bgView.addSubview(border)
        bgView.addSubview(memoTextView)
    }
    
    override func setupConstraints() {
        bgView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(16)
            make.verticalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(8)
        }
        
        titleTextField.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(bgView).inset(16)
        }
        
        border.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(12)
            make.leading.equalTo(titleTextField.snp.leading)
            make.trailing.equalTo(bgView.snp.trailing)
        }
        
        memoTextView.snp.makeConstraints { make in
            make.top.equalTo(border.snp.bottom).offset(4)
            make.leading.equalTo(bgView.snp.leading).offset(12)
            make.trailing.equalTo(bgView.snp.trailing).inset(16)
            make.bottom.equalTo(bgView.snp.bottom).inset(8)
        }
    }
    
    override func configureLayout() {
        super.configureLayout()
        bgView.backgroundColor = .systemGray5
        bgView.layer.cornerRadius = Resource.corner.defaultCornerRadius
        titleTextField.placeholder = Resource.placeholder.title.rawValue
        titleTextField.font = Resource.FontCase.regular15
        memoTextView.text = Resource.placeholder.memo.rawValue
        memoTextView.backgroundColor = .systemGray5
        memoTextView.font = Resource.FontCase.regular15
        memoTextView.textColor = .systemGray2
    }
}
