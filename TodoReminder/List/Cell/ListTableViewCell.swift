//
//  ListTableViewCell.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit
import SnapKit

class ListTableViewCell: BaseTableViewCell {
    let checkBox: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: Resource.ImageCase.inProgress.rawValue), for: .normal)
        button.tintColor = .lightGray
        return button
    }()
    private let titleStackView = CustomHorizontalStackView()
    private let priorityLabel = UILabel()
    private let titleLabel = UILabel()
    private let memoLabel = UILabel()
    private let descStackView = CustomHorizontalStackView()
    private let deadlineLabel = UILabel()
    private let tagLabel = UILabel()
    
    override func setupHierarchy() {
        contentView.addSubview(checkBox)
        contentView.addSubview(titleStackView)
        [priorityLabel, titleLabel].forEach {
            titleStackView.addArrangedSubview($0)
        }
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
        
        titleStackView.snp.makeConstraints { make in
            make.centerY.equalTo(checkBox.snp.centerY)
            make.leading.equalTo(checkBox.snp.trailing).offset(8)
            make.height.equalTo(20)
            make.trailing.lessThanOrEqualTo(contentView.safeAreaLayoutGuide).inset(16)
        }
        
        memoLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(titleStackView)
            make.top.equalTo(titleStackView.snp.bottom).offset(4)
        }
        
        descStackView.snp.makeConstraints { make in
            make.leading.equalTo(memoLabel.snp.leading)
            make.trailing.lessThanOrEqualTo(contentView.safeAreaLayoutGuide).inset(16)
            make.top.equalTo(memoLabel.snp.bottom).offset(4)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(8)
        }
    }
    
    override func configureLayout() {
        super.configureLayout()
        titleLabel.font = Resource.FontCase.regular16
        priorityLabel.textColor = .systemPink
        tagLabel.textColor = .systemBlue
        [priorityLabel, deadlineLabel, tagLabel, memoLabel].forEach {
            $0.font = Resource.FontCase.regular14
        }
        [memoLabel, deadlineLabel].forEach {
            $0.textColor = .lightGray
        }
    }
    
    func configureCell(_ data: Todo) {
        let checkImageName = data.isComplete ? Resource.ImageCase.complete.rawValue : Resource.ImageCase.inProgress.rawValue
        checkBox.setImage(UIImage(systemName: checkImageName), for: .normal)
        titleLabel.text = data.title
        memoLabel.text = data.memo
        priorityLabel.text = data.priority
        if let tag = data.tag { tagLabel.text = "#\(tag)" }
        if let date = data.deadline { deadlineLabel.text = formattedDateString(date: date) }
      
    }
}
