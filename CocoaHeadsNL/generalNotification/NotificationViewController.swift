//
//  NotificationViewController.swift
//  generalNotification
//
//  Created by Bart Hoffman on 10/03/2018.
//  Copyright © 2018 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var postImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {

        if let attachment = notification.request.content.attachments.first {
            if attachment.url.startAccessingSecurityScopedResource() {
                if let data = NSData(contentsOfFile: attachment.url.path) as Data? {
                    self.postImageView?.image = UIImage(data: data)
                    attachment.url.stopAccessingSecurityScopedResource()
                }
            }
        }
    }
}
