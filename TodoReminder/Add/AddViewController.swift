//
//  AddViewController.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit
import PhotosUI

final class AddViewController: BaseViewController {
    private let vm = AddViewModel()
    
    init(todoFromListVC: Todo?, viewType: Resource.ViewType) {
        super.init(nibName: nil, bundle: nil)
        self.vm.inputOriginalTodo.value = todoFromListVC
        self.viewType = viewType
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let repository = TodoRepository()
    var viewType: Resource.ViewType = .add
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bind()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // modal이 내려갈 때 NotificationCenter에 알림보내기 
        NotificationCenter.default.post(name: NSNotification.Name(Resource.NotificationCenterName.dismiss), object: nil, userInfo: nil)
    }
    
    override func setupHierarchy() {
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        navigationItem.rightBarButtonItem?.isEnabled = viewType == .edit
    }
    
    override func setupNavigation(_ title: String) {
        super.setupNavigation(viewType.rawValue)
        let leftBarItem = UIBarButtonItem(title: Resource.ButtonTitle.cancel.rawValue, style: .plain, target: self, action: #selector(cancelBtnTapped))
        navigationItem.leftBarButtonItem = leftBarItem
    }
    
    override func configureRightBarButton(title: String?, imageName: String?, action: Selector?) {
        super.configureRightBarButton(title: viewType.rightBarTitle, imageName: nil, action: #selector(saveBtnTapped))
    }
    
    override func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: ContentTableViewCell.identifier)
        tableView.register(AttributeTableViewCell.self, forCellReuseIdentifier: AttributeTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
    }
    
    @objc func saveBtnTapped(_ sender: UIButton) {
        vm.saveBtnTrigger.value = viewType
        dismiss(animated: true)
    }
    
    @objc func cancelBtnTapped(_ sender: UIButton) {
        vm.cancelBtnTrigger.value = ()
        dismiss(animated: true)
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        guard let text = sender.text else { return }
        let textCnt = text.trimmingCharacters(in: .whitespacesAndNewlines).count
        // 제목이 없거나 제목이 공백으로만 되어있는 경우
        if text.isEmpty || textCnt == 0 {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else { // 텍스트가 변할 때마다 temp값 변경
            vm.updateTitle.value = text
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    private func configurePHPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        transition(picker, type: .push)
    }
    
    private func bind() {
        // 저장 전 임시 데이터인 vm 내 tempTodo 데이터가 변경될 때마다 tableView 새로 그리기
        vm.outputTempTodo.bind { todo in
            self.tableView.reloadData()
        }
    }
}

// MARK: TableViewDelegate
extension AddViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // contentCell이면 높이 210 / attributeCell이면 높이 70
        return indexPath.row == 0 ? 210 : 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Resource.AddAttributeCase.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let attribute = Resource.AddAttributeCase.allCases[indexPath.row]
        
        switch attribute {
        case .content:
            let cell = tableView.dequeueReusableCell(withIdentifier: ContentTableViewCell.identifier, for: indexPath) as! ContentTableViewCell
            cell.memoTextView.delegate = self
            cell.titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            let tempTodo = vm.outputTempTodo.value
            cell.configureCell(tempTodo)
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: AttributeTableViewCell.identifier, for: indexPath) as! AttributeTableViewCell
            let tempTodo = vm.outputTempTodo.value
            let attribute = Resource.AddAttributeCase.allCases[indexPath.row]
            cell.configureCell(attribute, data: tempTodo)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 각 어떤 속성의 셀인지냐에 따라 다른 처리
        let attribute = Resource.AddAttributeCase.allCases[indexPath.row]
        let tempTodo = vm.outputTempTodo.value
        
        switch attribute {
        case .deadline:
            let vc = DateViewController(deadline: tempTodo.deadline)
            transition(vc)
            vc.sendDeadline = { deadline in
                self.vm.updateDeadline.value = deadline
            }
        case .tag:
            let vc = TagViewController(tag: tempTodo.tag)
            transition(vc)
            vc.sendTag = { tag in
                self.vm.updateTag.value = tag
            }
        case .priority:
            let vc = PriorityViewController(selectedIdx: tempTodo.priorityIdx)
            transition(vc)
            vc.sendPriorityIdx = { idx in
                self.vm.updatePriorityIdx.value = idx
            }
        case .addImage:
            configurePHPicker()
        default: break
        }
    }
}

// MARK: TextViewDelegate
extension AddViewController: UITextViewDelegate {
    // 텍스트뷰(메모)에 입력 시작했을 때
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor != .white { //텍스트가 아닌 placeholder 상태라면
            // placeholder 지우고
            textView.text = ""
            // 텍스트 컬러 변경
            textView.textColor = .white
        }
    }
    
    // 텍스트뷰(메모)에 입력끝났을 때
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = textView.text else { return }
        // 만약 입력된 텍스트가 없다면
        if text.isEmpty {
            // placeholder 설정 및 텍스트 컬러 변경
            textView.text = "메모"
            textView.textColor = .systemGray2
        }
    }
    
    // 텍스트뷰(메모) 내용이 바뀔 때
    func textViewDidChange(_ textView: UITextView) {
        // 내용 바뀔 때마다 temp값에 저장
        guard let text = textView.text else { return }
        vm.updateMemo.value = text
    }
}

// MARK: PHPickerDelegate
extension AddViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // itemProvider : 선택한 이미지와 관련된 데이터 정보들
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            // 여기는 mainThread
            itemProvider.loadObject(ofClass: UIImage.self) { [unowned self] image, error in
                // 이 코드 구문은 애플에서 global에서 처리하도록 해둬서 이미지를 대입해주는건 main으로 넘겨줘야함
                DispatchQueue.main.async {
                    // image가 NSItemProviderReading이라는 데이터 타입이기 때문에 UIImage로 변환할 수 있는지 확인
                    guard let convertedImage = image as? UIImage else { return }
                    self.vm.updateImage.value = convertedImage
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
}
