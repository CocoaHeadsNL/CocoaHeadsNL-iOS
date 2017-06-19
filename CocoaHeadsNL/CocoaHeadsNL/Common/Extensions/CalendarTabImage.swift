//
//  CalendarTabImage.swift
//  CocoaHeadsNL
//
//  Created by Bruno Scheele on 29/05/15.
//  Copyright (c) 2016 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    class func calendarTabImageWithCurrentDate() -> UIImage {
        return calendarTabImageWithDate(Date())
    }

    class func calendarTabImageWithDate(_ date: Date) -> UIImage {
        let dateFormatter = DateFormatter()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let maskView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))

        let calendarView = UIImageView()
        calendarView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        calendarView.image = UIImage(named: "EventsTabIcon")
        view.addSubview(calendarView)

        // Create the month

        dateFormatter.dateFormat = "MMM"
        let month = dateFormatter.string(from: date).uppercased()

        let monthLabel = UILabel(frame: CGRect(x: 0, y: 4, width: 30, height: 6))
        monthLabel.text = month
        monthLabel.font = UIFont.boldSystemFont(ofSize: 6)
        monthLabel.textAlignment = .center
        monthLabel.textColor = UIColor.white
        maskView.addSubview(monthLabel)

        // Create the day number

        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.string(from: date)

        let numberLabel = UILabel(frame: CGRect(x: 0, y: 10, width: 30, height: 17))
        numberLabel.text = day
        numberLabel.font = UIFont.boldSystemFont(ofSize: 14)
        numberLabel.textAlignment = .center
        view.addSubview(numberLabel)

        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        UIGraphicsBeginImageContextWithOptions(maskView.bounds.size, false, UIScreen.main.scale)
        maskView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let maskingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Mask month out of the image to show in tabBar.
        let resultImage = image?.maskImage(maskingImage!)
        return resultImage!
    }

    func maskImage(_ maskImage: UIImage) -> UIImage {
        let maskRef = maskImage.cgImage

        let mask = CGImage(maskWidth: (maskRef?.width)!, height: (maskRef?.height)!, bitsPerComponent: (maskRef?.bitsPerComponent)!, bitsPerPixel: (maskRef?.bitsPerPixel)!, bytesPerRow: (maskRef?.bytesPerRow)!, provider: (maskRef?.dataProvider!)!, decode: nil, shouldInterpolate: false)

        let masked = self.cgImage?.masking(mask!)!
        let maskedImage = UIImage(cgImage: masked!, scale: UIScreen.main.scale, orientation: .up)

        return maskedImage
    }
}
