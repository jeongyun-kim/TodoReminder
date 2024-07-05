//
//  UICollectionViewLayout + Extension.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/5/24.
//

import UIKit

extension UICollectionViewLayout {
    static func mainLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 8
        let inset: CGFloat = 16
        let width = (UIScreen.main.bounds.width - spacing - inset*2) / 2
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        layout.itemSize = CGSize(width: width, height: width*0.45)
        return layout
    }
}
