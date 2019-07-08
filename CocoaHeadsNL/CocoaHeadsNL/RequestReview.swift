//
//  RequestReview.swift
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 29/03/2017.
//  Copyright © 2017 Stichting CocoaheadsNL. All rights reserved.
//

import StoreKit

public class RequestReview: NSObject {

    static private let defaultKeyRatingLastRequestDate = "app_rating_last_request_date"

    static public func requestReview() {
        if #available(iOS 10.3, *) {
            if let lastRequestDate = UserDefaults.standard.object(forKey: RequestReview.defaultKeyRatingLastRequestDate) as? Date {
                if lastRequestDate.compare(Date()) == ComparisonResult.orderedAscending {
                    SKStoreReviewController.requestReview()
                    let reviewRequestDate = NSCalendar.current.date(byAdding: .day, value: 100, to: Date())
                    UserDefaults.standard.set(reviewRequestDate, forKey: defaultKeyRatingLastRequestDate)
                }
            } else {
                // Ask for first review 7 days from now
                let reviewRequestDate = NSCalendar.current.date(byAdding: .day, value: 7, to: Date())
                UserDefaults.standard.set(reviewRequestDate, forKey: defaultKeyRatingLastRequestDate)
            }
        }
    }
}
