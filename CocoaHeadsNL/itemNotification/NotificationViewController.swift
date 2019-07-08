//
//  NotificationViewController.swift
//  itemNotification
//
//  Created by Bart Hoffman on 10/03/2018.
//  Copyright © 2018 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import CloudKit

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var titlelabel: UILabel?
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var postImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        
        if let userInfo = notification.request.content.userInfo as NSDictionary as? [String: Any] {
            let ck = CKQueryNotification.init(fromRemoteNotificationDictionary: userInfo)!
            
            if let title = ck.recordFields?["title"] as? String,
                let name = ck.recordFields?["name"] as? String {
                self.titlelabel?.text = title
                self.nameLabel?.text = name
            }
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

}
