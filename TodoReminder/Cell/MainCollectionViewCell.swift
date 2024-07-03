//
//  MainCollectionViewCell.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit

final class MainCollectionViewCell: UICollectionViewCell {
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupConstraints()
        configureLayout()
    }
    
    private func setupHierarchy() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(countLabel)
    }
    
    private func setupConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.leading.top.equalTo(safeAreaLayoutGuide).offset(8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide).inset(12)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(8)
        }
        
        countLabel.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide).inset(12)
            make.centerY.equalTo(iconImageView.snp.centerY)
        }
    }
    
    private func configureLayout() {
        countLabel.font = Resource.FontCase.bold16
        titleLabel.font = Resource.FontCase.bold15
        backgroundColor = .systemGray5
        layer.cornerRadius = Resource.corner.defaultCornerRadius
    }
    
    func configureCell(_ data: TodoList) {
        titleLabel.text = data.listCase.title
        iconImageView.image = UIImage(systemName: data.listCase.imageName)
        iconImageView.tintColor = data.listCase.imageColor
        countLabel.text = "\(data.listCase.dbData.count)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
