//
//  CalendarTabImage.swift
//  CocoaHeadsNL
//
//  Created by Bruno Scheele on 29/05/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

extension UIImage
{
    class func calendarTabImageWithCurrentDate() -> UIImage
    {
        return calendarTabImageWithDate(NSDate())
    }
    
    class func calendarTabImageWithDate(date: NSDate) -> UIImage
    {
        let dateFormatter = NSDateFormatter()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let maskView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        let calendarView = UIImageView()
        calendarView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        calendarView.image = UIImage(named: "EventsTabIcon")
        view.addSubview(calendarView)
        
        // Create the month
        
        dateFormatter.dateFormat = "MMM"
        let month = dateFormatter.stringFromDate(date).uppercaseString
        
        let monthLabel = UILabel(frame: CGRect(x: 0, y: 4, width: 30, height: 6))
        monthLabel.text = month
        monthLabel.font = UIFont.boldSystemFontOfSize(6)
        monthLabel.textAlignment = .Center
        monthLabel.textColor = UIColor.whiteColor()
        maskView.addSubview(monthLabel)
        
        // Create the day number
        
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.stringFromDate(date)
        
        let numberLabel = UILabel(frame: CGRect(x: 0, y: 10, width: 30, height: 17))
        numberLabel.text = day
        numberLabel.font = UIFont.boldSystemFontOfSize(14)
        numberLabel.textAlignment = .Center
        view.addSubview(numberLabel)
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.mainScreen().scale)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        UIGraphicsBeginImageContextWithOptions(maskView.bounds.size, false, UIScreen.mainScreen().scale)
        maskView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let maskingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Mask month out of the image to show in tabBar.
        let resultImage = image.maskImage(maskingImage)
        return resultImage
    }
    
    func maskImage(maskImage: UIImage) -> UIImage
    {
        let maskRef = maskImage.CGImage
        
        let mask = CGImageMaskCreate(CGImageGetWidth(maskRef), CGImageGetHeight(maskRef), CGImageGetBitsPerComponent(maskRef), CGImageGetBitsPerPixel(maskRef), CGImageGetBytesPerRow(maskRef), CGImageGetDataProvider(maskRef), nil, false)
        
        let masked = CGImageCreateWithMask(self.CGImage, mask)!
        let maskedImage = UIImage(CGImage: masked, scale: UIScreen.mainScreen().scale, orientation: .Up)

        return maskedImage
    }
}
