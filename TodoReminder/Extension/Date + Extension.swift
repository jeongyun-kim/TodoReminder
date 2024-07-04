//
//  Date + Extension.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/4/24.
//

import UIKit

extension Date {
    static func dateCompare(deadline: Date?) -> Resource.DateCompareCase {
        guard let deadline else { return .none }
        let result:ComparisonResult = Date(timeIntervalSinceNow: 32400).compare(deadline)
        switch result {
        case .orderedAscending:
            return .future
        case .orderedSame:
            return .today
        case .orderedDescending:
            return .past
        default:
            return .none
        }
    }
}
