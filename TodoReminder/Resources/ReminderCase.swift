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
        }
    }
    
    var imageColor: UIColor {
        switch self {
        case .today:
            return .systemBlue
        case .schedule:
            return .systemRed
        case .all:
            return .lightGray
        case .flag:
            return .systemYellow
        case .complete:
            return .systemGreen
        }
    }
    
    var dbData: Results<Todo> {
        let realm = try! Realm()
        let allData = realm.objects(Todo.self)
        switch self {
        case .today:
            return allData.where({ $0.deadline == Date() })
        case .schedule:
            return allData.where({ $0.deadline != nil && $0.deadline != Date() })
        case .all:
            return allData
        case .flag:
            return allData.where({ $0.isFlag })
        case .complete:
            return allData.where({ $0.isComplete })
        }
    }
}

