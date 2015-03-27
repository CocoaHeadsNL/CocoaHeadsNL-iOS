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
    private var collapseDetailViewController = true
    var selectedObject: PFObject?

    override func viewDidLoad() {
        self.delegate = self
        self.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
    }
    
    // MARK: - UISplitViewControllerDelegate
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        return false
    }
    
    func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController!) -> UIViewController? {
        /*
        In this delegate method, the reverse of the collapsing procedure described above needs to be
        carried out if a list is being displayed. The appropriate controller to display in the detail area
        should be returned. If not, the standard behavior is obtained by returning nil.
        */
        //var primary = splitViewController.viewControllers[0] as UITabBarController
        
        //if we selected an object we need to pass the current viewcontroller on screen
        // we need to pass an empty screen if no object present or no selection was made
        
        
        let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("detailTableViewController") as DetailTableViewController
        let detailNavigation = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("detailNavigationController") as UINavigationController
        detailNavigation.viewControllers[0] = detailViewController
        detailViewController.selectedObject = self.selectedObject
        
        return detailNavigation
    }
    
    func primaryViewControllerForExpandingSplitViewController(splitViewController: UISplitViewController) -> UIViewController? {
        var primary = splitViewController.viewControllers[0] as UITabBarController
        var primaryNavigation = primary.selectedViewController as UINavigationController
        if let last = primaryNavigation.viewControllers.last as? DetailTableViewController {
            self.selectedObject = last.selectedObject
        } else {
            self.selectedObject = nil
        }
        primaryNavigation.popViewControllerAnimated(false)
        
        return primary
    }


    func splitViewController(splitViewController: UISplitViewController, showDetailViewController vc: UIViewController, sender: AnyObject?) -> Bool {
        
        if splitViewController.collapsed {
            var master = splitViewController.viewControllers[0] as UITabBarController
            var masterNavigation = master.selectedViewController as UINavigationController
            
            masterNavigation.showViewController(vc, sender: self)
            
            return true
        }
        return false
    }

}
