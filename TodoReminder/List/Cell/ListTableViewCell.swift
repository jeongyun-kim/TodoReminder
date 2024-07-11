//
//  ListTableViewCell.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit
import SnapKit

class ListTableViewCell: BaseTableViewCell {
    let completeButton: UIButton = {
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
        contentView.addSubview(completeButton)
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
        completeButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(8)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(16)
        }
        
        titleStackView.snp.makeConstraints { make in
            make.centerY.equalTo(completeButton.snp.centerY)
            make.leading.equalTo(completeButton.snp.trailing).offset(8)
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
    
    // complete 버튼을 눌렀을 때, 태그가 없는 셀인데 태그가 생김
    // -> 셀을 재사용하기때문 -> 셀 내 필수요소인 제목을 제외하고는 모두 공백으로 재구성해서 재사용하기 
    override func prepareForReuse() {
        super.prepareForReuse()
        memoLabel.text = ""
        priorityLabel.text = ""
        tagLabel.text = ""
        deadlineLabel.text = ""
    }
    
    func configureCell(_ data: Todo) {
        let checkImageName = data.isComplete ? Resource.ImageCase.complete.rawValue : Resource.ImageCase.inProgress.rawValue
        completeButton.setImage(UIImage(systemName: checkImageName), for: .normal)
        titleLabel.text = data.todoTitle
        memoLabel.text = data.memo
        
        // 저장되어있는 우선순위의 인덱스로 중요도 구하고 중요도의 느낌표 가져오기
        if let idx = data.priorityIdx {
            priorityLabel.text = Resource.PriorityCase.allCases[idx].bang
        }
        // data내 tag가 있는지, 있으면 공백으로 되어있진 않은지 확인
        if let tag = data.tag, tag.components(separatedBy: " ").joined().count > 0 {
            tagLabel.text = "#\(tag)"
        }
        // 리스트셀에 맞는 마감일 String 보여주기
        if let deadline = data.deadline {
            deadlineLabel.text = DateFormatterManager.shared.dateToStringForCell(deadline)
        }
      
    }
}


