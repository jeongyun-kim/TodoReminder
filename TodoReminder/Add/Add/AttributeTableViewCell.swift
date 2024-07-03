//
//  AddTableViewCell.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit
import SnapKit

final class AttributeTableViewCell: BaseTableViewCell {
    private let bgView = UIView()
    private let titleLabel = UILabel()
    private let attributeLabel = UILabel()
    private let goImageView = UIImageView()
    
    override func setupHierarchy() {
        contentView.addSubview(bgView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(attributeLabel)
        contentView.addSubview(goImageView)
    }
    
    override func setupConstraints() {
        bgView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(16)
            make.verticalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(bgView.snp.leading).offset(16)
            make.centerY.equalTo(bgView.snp.centerY)
        }
        
        attributeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(bgView.snp.centerY)
            make.trailing.greaterThanOrEqualTo(goImageView.snp.leading).offset(-8)
        }
        
        goImageView.snp.makeConstraints { make in
            make.centerY.equalTo(bgView.snp.centerY)
            make.trailing.equalTo(bgView.snp.trailing).inset(12)
        }
    }
    
    override func configureLayout() {
        super.configureLayout()
        bgView.layer.cornerRadius = Resource.corner.defaultCornerRadius
        bgView.backgroundColor = .systemGray5
        titleLabel.font = Resource.FontCase.regular15
        attributeLabel.font = Resource.FontCase.regular14
        goImageView.image = UIImage(systemName: Resource.ImageCase.go.rawValue)
        goImageView.tintColor = .lightGray
    }
    
    func configureCell(_ title: String, attribute: String) {
        titleLabel.text = title
        attributeLabel.text = attribute
    }
}