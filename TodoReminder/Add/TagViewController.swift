//
//  TagViewController.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/3/24.
//

import UIKit

final class TagViewController: BaseViewController {
    init(tag: String?) {
        super.init(nibName: nil, bundle: nil)
        self.tag = tag
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var tag: String?
    // 현재 적힌 태그명 보내주는 클로저
    var sendTag: ((String) -> Void)?
    
    private let tagTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Resource.placeholder.tag.rawValue
        return textField
    }()
    private let border = CustomBorder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 이미 등록한 태그가 있다면 세팅해주기
        if let tag {
            tagTextField.text = tag
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let tag = tagTextField.text else { return }
        sendTag?(tag)
    }
    
    override func setupHierarchy() {
        view.addSubview(tagTextField)
        view.addSubview(border)
    }
    
    override func setupConstraints() {
        tagTextField.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        border.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(tagTextField)
            make.top.equalTo(tagTextField.snp.bottom).offset(4)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        tagTextField.becomeFirstResponder()
    }
    
    override func setupNavigation(_ title: String) {
        super.setupNavigation(Resource.AddAttributeCase.tag.rawValue)
    }
}
