//
//  TodoErrorCase.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/4/24.
//

import Foundation

enum TodoErrorCase: String, Error {
    case createError = "저장에 실패했어요"
    case deleteError = "삭제에 실패했어요"
    case updateError = "업데이트에 실패했어요"
}
