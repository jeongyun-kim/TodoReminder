//
//  PriorityViewController.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/3/24.
//

import UIKit
import SnapKit

final class PriorityViewController: BaseViewController {
    init(selectedIdx: Int?) {
        super.init(nibName: nil, bundle: nil)
        self.selectedIdx = selectedIdx
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let prioritySegment = UISegmentedControl()
    var getPriority: ((Int, String) -> Void)?
    var selectedIdx: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectedIdx = selectedIdx {
            prioritySegment.selectedSegmentIndex = selectedIdx
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let idx = prioritySegment.selectedSegmentIndex
        guard let selectedSegmentTitle = prioritySegment.titleForSegment(at: idx) else { return }
        getPriority?(idx, selectedSegmentTitle)
    }
    
    override func setupHierarchy() {
        view.addSubview(prioritySegment)
    }
    
    override func setupConstraints() {
        prioritySegment.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        let segmentTitles = Resource.PrioritySegmentTitleCase.allCases
        for i in 0..<segmentTitles.count {
            prioritySegment.insertSegment(withTitle: segmentTitles[i].rawValue, at: i, animated: true)
        }
    }
    
    override func setupNavigation(_ title: String) {
        super.setupNavigation(AddAttributeCase.priority.rawValue)
    }
}
