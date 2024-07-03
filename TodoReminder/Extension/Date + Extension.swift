//
//  Date + Extension.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/3/24.
//

import Foundation

extension Date {
    func dateCompare(deadline: Date) -> Bool {
        var isFuture: Bool = false
        let result:ComparisonResult = self.compare(deadline)
        switch result {
            case .orderedAscending:
                isFuture = true
            case .orderedSame:
                isFuture = false
            default:
                break
        }
        return isFuture
    }
}
