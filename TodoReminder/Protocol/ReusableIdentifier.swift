//
//  ReusableIdentifier.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/2/24.
//

import UIKit

protocol ReusableIdentifier {
    static var identifier: String { get }
}

extension UIView: ReusableIdentifier {
    static var identifier: String {
        return String(describing: self)
    }
}
