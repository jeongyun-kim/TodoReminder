//
//  ReminderCase.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit
import RealmSwift

enum ReminderCase: String, CaseIterable {
    case today
    case schedule
    case all
    case flag
    case complete
    case bookmark
    
    var title: String {
        switch self {
        case .today:
            "오늘"
        case .schedule:
            "예정"
        case .all:
            "전체"
        case .flag:
            "깃발표시"
        case .complete:
            "완료됨"
        case .bookmark:
            "즐겨찾기"
        }
    }
    
    var imageName: String {
        switch self {
        case .today:
            return "sun.max.circle.fill"
        case .schedule:
            return "calendar.circle.fill"
        case .all:
            return "tray.circle.fill"
        case .flag:
            return "flag.circle.fill"
        case .complete:
            return "checkmark.circle.fill"
        case .bookmark:
            return "bookmark.circle.fill"
        }
    }

    var imageColor: String {
        switch self {
        case .today:
            return UIColor.systemBlue.toHexStr()
        case .schedule:
            return UIColor.systemRed.toHexStr()
        case .all:
            return UIColor.lightGray.toHexStr()
        case .flag:
            return UIColor.systemYellow.toHexStr()
        case .complete:
            return UIColor.systemGreen.toHexStr()
        case .bookmark:
            return UIColor.systemOrange.toHexStr()
        }
    }
        
}
