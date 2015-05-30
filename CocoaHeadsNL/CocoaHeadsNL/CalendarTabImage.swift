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
        
        let calendarView = UIImageView()
        calendarView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        if let calendarImage = UIImage(named: "EventsTabIcon") {
            calendarView.image = calendarImage
        }
        view.addSubview(calendarView)
        
        // Create the month
        // TODO: Mask month out of the image to show in tabBar.
        
        dateFormatter.dateFormat = "MMM"
        let month = dateFormatter.stringFromDate(date).uppercaseString
        
        let monthLabel = UILabel(frame: CGRect(x: 8, y: 4, width: 14, height: 4))
        monthLabel.text = month
        monthLabel.font = UIFont.boldSystemFontOfSize(6)
        monthLabel.textAlignment = .Center
        monthLabel.textColor = UIColor.whiteColor()
        view.addSubview(monthLabel)
        
        // Create the day number
        
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.stringFromDate(date)
        
        let numberLabel = UILabel(frame: CGRect(x: 4, y: 9, width: 22, height: 17))
        numberLabel.text = day
        numberLabel.font = UIFont.boldSystemFontOfSize(14)
        numberLabel.textAlignment = .Center
        view.addSubview(numberLabel)
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.mainScreen().scale)
        // TODO: Figure out why `drawViewHierarchyInRect` result in blank image.
//        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        // Create a mask for the month text.
        view.backgroundColor = UIColor.blackColor()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
