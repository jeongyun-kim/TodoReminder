//
//  Observable.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/10/24.
//

import Foundation

final class Observable<T> {
    var closure: ((T) -> Void)?
    
    var value: T {
        didSet {
            closure?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ closure: @escaping (T) -> Void) {
        //closure(value)
        self.closure = closure
    }
}
