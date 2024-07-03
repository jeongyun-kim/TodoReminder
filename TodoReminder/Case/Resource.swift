//
//  Resource.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit

enum Resource {
    enum FontCase {
        static let bold16 = UIFont.boldSystemFont(ofSize: 26)
        static let bold15 = UIFont.boldSystemFont(ofSize: 15)
        static let regular16 = UIFont.systemFont(ofSize: 16)
        static let regular15 = UIFont.systemFont(ofSize: 15)
        static let regular14 = UIFont.systemFont(ofSize: 14)
    }
    
    enum placeholder: String {
        case title = "제목"
        case memo = "메모"
        case tag = "태그를 입력해보세요"
    }
    
    enum addTodo: String {
        case deadline = "마감일"
        case tag = "태그"
        case priority = "우선순위"
        case addImage = "이미지 추가 "
    }
    
    enum corner {
        static let defaultCornerRadius: CGFloat = 10
    }
    
    enum ImageCase: String {
        case go = "chevron.right"
        case inProgress = "circle"
        case complete = "checkmark.circle.fill"
        case add = "plus.circle.fill"
        case more = "ellipsis.circle"
    }
    
    enum transitionCase {
        case push
        case present
    }
    
    enum NotificationCenterName {
        static let dismiss = "DismissAddVC"
    }
}

enum AddAttributeCase: String, CaseIterable {
    case content
    case deadline = "마감일"
    case tag  = "태그"
    case priority = "우선순위"
    case addImage = "이미지 추가"
}
