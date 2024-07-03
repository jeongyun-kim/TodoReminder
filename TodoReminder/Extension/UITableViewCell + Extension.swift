//
//  UITableViewCell + Extension.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/3/24.
//

import UIKit

extension UITableViewCell {
    func formattedDateString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "YYYY.M.d."
        return formatter.string(from: date)
    }
}
