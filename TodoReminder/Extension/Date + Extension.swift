//
//  Date + Extension.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/4/24.
//

import UIKit

extension Date {
    // 현재 날짜랑 마감일에서 시간은 동일하게 -> 년월일만 비교할 수 있게
    static func getRemovedTimeDate(preDate: Date, preDeadline: Date) -> [Date] {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        
        let todayDateString = formatter.string(from: preDate)
        let deadlineString = formatter.string(from: preDeadline)
        
        if let postDate = formatter.date(from: todayDateString), let postDeadline = formatter.date(from: deadlineString) {
            return [postDate, postDeadline]
        } else {
            return []
        }
    }
    
    static func dateCompare(deadline: Date?) -> Resource.DateCompareCase {
        guard let deadline else { return .none }
        // 마감일과 오늘 날짜 비교할 때, 시간은 제외하고 년월일만 비교해줘야함
        // -> 현재 날짜, 마감일 보내서 두 데이터 모두 시간 제외한 Date 타입으로 새로 가져와서 비교하기
        let postDateArray = getRemovedTimeDate(preDate: Date(), preDeadline: deadline)
        
        let postDate = postDateArray[0]
        let postDeadline = postDateArray[1]
        
        let result:ComparisonResult = postDate.compare(postDeadline)
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
    
    // AddVC 내 테이블뷰셀에 들어가는지 / ListVC 내 테이블뷰 셀에 들어가는지에 따라 dateFormat 다르게해서 String으로 변환한 결과 보내기 
    static func dateFormattedString(_ date: Date, type: Resource.DateFormatUsage) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = type == .list ? "YYYY.M.d." : "YYYY.MM.dd (EEEEE)"
        let result = formatter.string(from: date)
        return result
    }
}
