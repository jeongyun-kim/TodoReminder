//
//  DateViewController.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/3/24.
//

import UIKit
import SnapKit
import Toast

final class DateViewController: BaseViewController {
    init(deadline: Date?) {
        super.init(nibName: nil, bundle: nil)
        print("DateVC init")
        self.vm.inputDeadline.value = deadline
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("DateVC deinit")
    }
    
    private let vm = DateViewModel()
    private let datePicker = UIDatePicker()

    // 현재 선택한 마감일 보내주는 클로저
    var sendDeadline: ((Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let deadline = vm.outputDeadline.value.1 else { return }
        sendDeadline?(deadline)
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
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerDidChanged), for: .valueChanged)
        datePicker.tintColor = .systemPink
        datePicker.locale = Locale(identifier: "ko_KR")
    }
    
    @objc func datePickerDidChanged(_ sender: UIDatePicker) {
        // 달력 내 날짜 누를때마다 마감일 데이터 변경
        vm.inputDeadline.value = sender.date
    }
    
    private func bind() {
        vm.outputDeadline.bind({ [weak self] (message, deadline) in
            if let message {
                // 만약 과거를 선택했다면 과거는 선택할 수 없다는 메시지 출력 및 네비게이션 컨트롤러 인터랙션 막아 뒤로갈 수 없게 하기
                self?.view.makeToast(message)
                self?.navigationController?.navigationBar.isUserInteractionEnabled = false
            } else {
                // 이미 세팅되어있던 날짜가 있다면 그 날짜로 변경해주기
                // 현재 또는 미래 날짜이기때문에 
                guard let deadline else { return }
                self?.datePicker.date = deadline
                self?.navigationController?.navigationBar.isUserInteractionEnabled = true
            }
        }, initRun: true)
    }
}


