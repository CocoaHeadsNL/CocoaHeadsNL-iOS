//
//  SplitViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 14/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    override func viewDidLoad() {
        self.delegate = self
        self.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SplitViewController.searchNotification(_:)), name: searchNotificationName, object: nil)
        
        //Inspect paste board for userInfo
        if let pasteBoard = UIPasteboard(name: searchPasteboardName, create: false) {
            let uniqueIdentifier = pasteBoard.string
            if let components = uniqueIdentifier?.componentsSeparatedByString(":") {
                if components.count > 0 {
                    let type = components[0]
                    displayTabForType(type)
                }
            }
        }
    }
    func searchNotification(notification:NSNotification) -> Void {
        guard let userInfo = notification.userInfo as? Dictionary<String,String> else {
            return
        }
        
        if let type = userInfo["type"] {
            displayTabForType(type)
        }
    }
    
    func displayTabForType(type: String) {
        guard let tabBarController = self.viewControllers[0] as? UITabBarController else {
            return
        }
        
        if type == "meetup" {
            tabBarController.selectedIndex = 0
        } else if type == "job" {
            tabBarController.selectedIndex = 1
        }
    }
    

    // MARK: - UISplitViewControllerDelegate

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        if let primaryTab = primaryViewController as? UITabBarController, _ = primaryTab.selectedViewController as? UINavigationController {
            return true
        }
        return false
    }

    func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        if let tabBarController = primaryViewController as? UITabBarController, navigationController = tabBarController.selectedViewController as? UINavigationController where navigationController.childViewControllers.count > 1 {
            guard let poppedControllers = navigationController.popToRootViewControllerAnimated(false) else {
                return nil
            }
            let childNavigationController = UINavigationController()
            childNavigationController.viewControllers = poppedControllers
            return childNavigationController
        }
        return nil
    }

    func splitViewController(splitViewController: UISplitViewController, showDetailViewController vc: UIViewController, sender: AnyObject?) -> Bool {
        if splitViewController.collapsed, let master = splitViewController.viewControllers[0] as? UITabBarController, masterNavigation = master.selectedViewController as? UINavigationController {
            masterNavigation.showViewController(vc, sender: self)
            return true
        } else if let masterNavigation = splitViewController.viewControllers[1] as? UINavigationController {
            masterNavigation.setViewControllers([vc], animated: true)
            return true
        }
        return false
    }
}
