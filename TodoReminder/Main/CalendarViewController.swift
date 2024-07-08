//
//  CalendarViewController.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/5/24.
//

import UIKit
import FSCalendar
import SnapKit

final class CalendarViewController: BaseViewController {
    private let repository = TodoRepository()
    private var list: [Todo] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private let calendar = FSCalendar()
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCalendar()
    }
    
    override func setupNavigation(_ title: String) {
        super.setupNavigation("캘린더")
    }
    
    override func setupHierarchy() {
        view.addSubview(calendar)
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        calendar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(calendar.snp.width)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(calendar.snp.bottom)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
    }
    
    override func setupUI() {
        super.setupUI()
    }
    
    private func configureCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
        calendar.appearance.titleDefaultColor = .white
        calendar.appearance.titleFont = Resource.FontCase.regular15
        calendar.appearance.weekdayFont = Resource.FontCase.bold15
        calendar.appearance.weekdayTextColor = .white
        calendar.appearance.headerTitleColor = .white
        calendar.appearance.headerTitleFont = Resource.FontCase.bold15
        calendar.scrollDirection = .vertical
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.appearance.todayColor = .systemGray5
        calendar.appearance.selectionColor = ReminderCase.schedule.imageColor
    }
    
    @objc public func completeBtnTapped(_ sender: UIButton) {
        repository.updateItem {
            list[sender.tag].isComplete.toggle()
            tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
        }
    }
}


extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints { make in
            make.size.equalTo(bounds.size)
        }
        view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        list = repository.readFilteredDateItem(date)
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.identifier, for: indexPath) as! ListTableViewCell
        cell.configureCell(list[indexPath.row])
        cell.completeButton.tag = indexPath.row
        cell.completeButton.addTarget(self, action: #selector(completeBtnTapped), for: .touchUpInside)
        return cell
    }
}
