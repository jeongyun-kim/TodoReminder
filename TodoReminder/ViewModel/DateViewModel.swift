//
//  DateViewModel.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/10/24.
//

import Foundation

final class DateViewModel {
    private let dateFormatter = DateFormatterManager.shared
    
    // Input
    var inputDeadline: Observable<Date?> = Observable(nil)
    
    // Output
    var outputDeadline: Observable<(String?, Date?)> = Observable((nil, nil))
    
    init() {
        print("DateVM init")
        inputDeadline.bind { [weak self] date in
            self?.validateDeadline(date)
        }
    }
    
    deinit {
        print("DateVM deinit")
    }
    
    private func validateDeadline(_ date: Date?) {
        guard let deadline = date else { return }
        let result = dateFormatter.dateCompare(deadline: deadline)
        if result == .past {
            let message = "과거는 마감일로 지정할 수 없어요"
            outputDeadline.value = (message, nil)
        } else {
            outputDeadline.value = (nil, deadline)
        }
    }
}
