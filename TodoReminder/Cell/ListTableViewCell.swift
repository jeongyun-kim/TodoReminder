//
//  ListTableViewCell.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit
import SnapKit

class ListTableViewCell: BaseTableViewCell {
    private let checkBox: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: Resource.ImageCase.inProgress.rawValue)
        imageView.tintColor = .lightGray
        return imageView
    }()
    private let titleLabel = UILabel()
    private let memoLabel = UILabel()
    private let descStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    private let deadlineLabel = UILabel()
    private let tagLabel = UILabel()
    
    override func setupHierarchy() {
        contentView.addSubview(checkBox)
        contentView.addSubview(titleLabel)
        contentView.addSubview(memoLabel)
        contentView.addSubview(descStackView)
        [deadlineLabel, tagLabel].forEach {
            descStackView.addArrangedSubview($0)
        }
    }
    
    override func setupConstraints() {
        checkBox.snp.makeConstraints { make in
            make.size.equalTo(25)
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(8)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(checkBox.snp.centerY)
            make.leading.equalTo(checkBox.snp.trailing).offset(8)
            make.height.equalTo(20)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(16)
        }
        
        memoLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        descStackView.snp.makeConstraints { make in
            make.leading.equalTo(memoLabel.snp.leading)
            make.top.equalTo(memoLabel.snp.bottom).offset(4)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(8)
        }
    }
    
    override func configureLayout() {
        super.configureLayout()
        titleLabel.font = Resource.FontCase.regular16
        memoLabel.font = Resource.FontCase.regular15
        memoLabel.textColor = .lightGray
        deadlineLabel.textColor = .lightGray
        tagLabel.textColor = .systemBlue
        deadlineLabel.backgroundColor = .white
    }
    
    func configureCell(_ data: Todo) {
        titleLabel.text = data.title
        memoLabel.text = data.memo
    }
}
