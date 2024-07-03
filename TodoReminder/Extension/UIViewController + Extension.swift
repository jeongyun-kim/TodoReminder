//
//  UIViewController + Extension.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit

extension UIViewController {
    func transition(_ vc: UIViewController, type: Resource.transitionCase) {
        switch type {
        case .present:
            present(vc, animated: true)
        case .push:
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func getDatePickerSelectedDate(date: Date) -> String {
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd (EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}
