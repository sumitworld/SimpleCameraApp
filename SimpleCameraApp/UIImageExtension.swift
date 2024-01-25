//
//  UIImageExtension.swift
//  SimpleCameraApp
//
//  Created by Vivek Parmar on 2024-01-25.
//

import Foundation
import UIKit

extension UIImage {
    func fixedOrientation() -> UIImage {
        guard imageOrientation != .up else {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage ?? self
    }
}
