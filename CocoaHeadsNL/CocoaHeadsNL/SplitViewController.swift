//
//  SplitViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 14/03/15.
//  Copyright (c) 2016 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    override func viewDidLoad() {
        self.delegate = self
        self.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible

        NotificationCenter.default.addObserver(self, selector: #selector(SplitViewController.searchNotification(_:)), name: NSNotification.Name(rawValue: searchNotificationName), object: nil)

        //Inspect paste board for userInfo
        if let pasteBoard = UIPasteboard(name: UIPasteboardName(rawValue: searchPasteboardName), create: false) {
            let uniqueIdentifier = pasteBoard.string
            if let components = uniqueIdentifier?.components(separatedBy: ":") {
                if components.count > 0 {
                    let type = components[0]
                    displayTabForType(type)
                }
            }
        }
    }
    @objc func searchNotification(_ notification: Notification) {
        guard let userInfo = (notification as NSNotification).userInfo as? Dictionary<String, String> else {
            return
        }

        if let type = userInfo["type"] {
            displayTabForType(type)
        }
    }

    func displayTabForType(_ type: String) {
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

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let primaryTab = primaryViewController as? UITabBarController, let _ = primaryTab.selectedViewController as? UINavigationController {
            return true
        }
        return false
    }

    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        if let tabBarController = primaryViewController as? UITabBarController, let navigationController = tabBarController.selectedViewController as? UINavigationController, navigationController.childViewControllers.count > 1 {
            guard let poppedControllers = navigationController.popToRootViewController(animated: false) else {
                return nil
            }
            let childNavigationController = UINavigationController()
            childNavigationController.viewControllers = poppedControllers
            return childNavigationController
        }
        return nil
    }

    func splitViewController(_ splitViewController: UISplitViewController,
                             showDetail detailVc: UIViewController,
                             sender: Any?) -> Bool {
        if splitViewController.isCollapsed, let master = splitViewController.viewControllers[0] as? UITabBarController, let masterNavigation = master.selectedViewController as? UINavigationController {
            masterNavigation.show(detailVc, sender: self)
            return true
        } else if let masterNavigation = splitViewController.viewControllers[1] as? UINavigationController {
            masterNavigation.setViewControllers([detailVc], animated: true)
            return true
        }
        return false
    }
}
