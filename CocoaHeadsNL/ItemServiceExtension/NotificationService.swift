//
//  NotificationService.swift
//  ItemServiceExtension
//
//  Created by Bart Hoffman on 11/03/2018.
//  Copyright © 2018 Stichting CocoaheadsNL. All rights reserved.
//

import UserNotifications
import CloudKit

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            
            if let userInfo = request.content.userInfo as NSDictionary as? [String: Any] {
                let ck = CKQueryNotification.init(fromRemoteNotificationDictionary: userInfo)
                
                if let title = ck.recordFields?["title"] as? String,
                    let name = ck.recordFields?["name"] as? String,
                    let imageUrl = ck.recordFields?["imageUrl"] as? String {
                    
                    bestAttemptContent.title = title
                    bestAttemptContent.body = name
                    
                    if let fileUrl = URL(string: imageUrl) {
                        
                        //let request = NSURLRequest(url: fileUrl)
                        URLSession.shared.downloadTask(with: fileUrl, completionHandler: { (fileLocation, response, err) in
                            
                            //create attachment from file at url in folder
                            if let location = fileLocation, err == nil {
                                let tmpDirectory = NSTemporaryDirectory()
                                let tmpFile = "file:".appending(tmpDirectory).appending(fileUrl.lastPathComponent)
                                let tmpUrl = URL.init(string: tmpFile)!
                                
                                do {
                                    try? FileManager.default.copyItem(at: location, to: tmpUrl)
                                    
                                    if let attachment = try? UNNotificationAttachment(identifier: "", url: tmpUrl, options: nil) {
                                        self.bestAttemptContent?.attachments = [attachment]
                                        contentHandler(bestAttemptContent)
                                    }
                                }
                            }
                        }) .resume()
                    }
                }
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

