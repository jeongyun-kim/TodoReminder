//
//  UIView + Extension.swift
//  TodoReminder
//
//  Created by 김정윤 on 7/5/24.
//

import UIKit

extension UIView {
    // 이미지를 Document에 저장
    func saveImageToDocument(image: UIImage, imageName: String) {
        // Document 폴더 위치 찾기
        // - userDomainMask : 사용자 홈 디렉토리 = 사용자 관련 파일이 저장되는 곳
        guard let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first else { return }
            
        // 이미지를 저장할 경로(파일명) 지정
        // - imageName이라는 이름으로 이미지 저장
        // - conformingTo: 확장자는 jpeg로 지정
        let fileURL = documentDirectory.appendingPathComponent("\(imageName)", conformingTo: .jpeg)
            
        // 이미지 압축
        // - jpegData : jpeg이미지를 압축할거야
        // - compressionQuality : 압축률
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
            
        // 이미지 파일 저장
        do {
            try data.write(to: fileURL)
        } catch {
            print("file save failed T^T", error)
        }
    }
    
    // Document로부터 이미지 읽어오기
    func loadImageFromDocument(imageName: String) -> UIImage? {
        guard let documentDirectory = FileManager.default.urls(
                   for: .documentDirectory,
                   in: .userDomainMask).first else { return nil }
                
        let fileURL = documentDirectory.appendingPathComponent("\(imageName)", conformingTo: .jpeg)
        //이 경로에 실제로 파일이 존재하는 지 확인 후 있으면 이미지를 / 없으면 nil을 반환
        guard FileManager.default.fileExists(atPath: fileURL.path()) else { return nil }
        return UIImage(contentsOfFile: fileURL.path())
    }
    
    func removeImageFromDocument(imageName: String) {
        if let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first {
            
            let fileURL = documentDirectory.appendingPathComponent("\(imageName)", conformingTo: .jpeg)
            
            if FileManager.default.fileExists(atPath: fileURL.path()) {
                // remove를 하는 동안에는 이미지를 가져갈 수 없게
                do {
                    try FileManager.default.removeItem(atPath: fileURL.path())
                } catch {
                    print("file remove error", error)
                }
            } else {
                print("file no exist")
            }
        }
    }
}
