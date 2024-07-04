//
//  DateViewController.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/3/24.
//

import UIKit
import SnapKit

final class DateViewController: BaseViewController {
    init(deadline: Date?) {
        super.init(nibName: nil, bundle: nil)
        self.deadline = deadline
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var navigationTitle: String = ""
    private let datePicker = UIDatePicker()
    var getDate: ((Date) -> Void)?
    var deadline: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 만약 마감일이 이미 설정되어있으면 해당 날짜로 선택된 상태 보여주기
        if let deadline {
            datePicker.date = deadline
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let deadline = deadline else { return }
        getDate?(deadline)
    }
    
    override func setupHierarchy() {
        view.addSubview(datePicker)
    }
    
    override func setupConstraints() {
        datePicker.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(datePicker.snp.width)
        }
    }
    
    override func setupNavigation(_ title: String) {
        super.setupNavigation(Resource.AddAttributeCase.deadline.rawValue)
    }
    
    override func setupUI() {
        super.setupUI()
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(datePickerDidChanged), for: .valueChanged)
        datePicker.tintColor = .systemPink
        datePicker.locale = Locale(identifier: "ko_KR")
    }
    
    @objc func datePickerDidChanged(_ sender: UIDatePicker) {
        deadline = sender.date
    }
}


