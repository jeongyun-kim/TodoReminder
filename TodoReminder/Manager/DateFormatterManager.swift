//
//  DateFormatterManager.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/10/24.
//

import Foundation

final class DateFormatterManager {
    private init() { }
    static let shared = DateFormatterManager()
    static let formatter = DateFormatter()
    
    var todayDate: Date {
        return Date(timeIntervalSinceNow: 32400)
    }
    
    // AddVC 내 테이블뷰셀에 들어가는지 / ListVC 내 테이블뷰 셀에 들어가는지에 따라 dateFormat 다르게해서 String으로 변환한 결과 보내기
    func dateToStringForCell(_ date: Date, type: Resource.DateFormatUsage = .list) -> String {
        let formatter = DateFormatterManager.formatter
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = type == .list ? "YYYY.M.d." : "YYYY.MM.dd (EEEEE)"
        let result = formatter.string(from: date)
        return result
    }
    
    // 현재 날짜랑 마감일에서 시간은 동일하게 -> 년월일만 비교할 수 있게
    func getRemovedTimeDate(preDate: Date) -> Date? {
        let formatter = DateFormatterManager.formatter
        formatter.dateFormat = "YYYY-MM-dd"
        let dateString = formatter.string(from: preDate)
        guard let result = formatter.date(from: dateString) else { return nil }
        return result
    }
    
    func dateCompare(deadline: Date?) -> Resource.DateCompareCase {
        guard let deadline else { return .none }
        // 마감일과 오늘 날짜 비교할 때, 시간은 제외하고 년월일만 비교해줘야함
        // -> 현재 날짜, 마감일 보내서 두 데이터 모두 시간 제외한 Date 타입으로 새로 가져와서 비교하기
        guard let postTodayDate = getRemovedTimeDate(preDate: Date()),
                let postDeadlineDate = getRemovedTimeDate(preDate: deadline) else { return .none}
       
        let result:ComparisonResult = postTodayDate.compare(postDeadlineDate)
        
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