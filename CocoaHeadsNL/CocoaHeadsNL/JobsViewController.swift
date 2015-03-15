//
//  JobsViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 07/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit

class JobsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
    var cellIdentifier = "jobsCollectionViewCellIdentifier"
    var jobsModel = JobsModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.registerClass(NSClassFromString("UICollectionViewCell"), forCellWithReuseIdentifier: cellIdentifier)
    }

    //MARK: - UICollectionViewDataSource methods
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jobsModel.jobsArray.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        
        var job = jobsModel.jobsArray[indexPath.row] as PFObject
        
//        var vacancyLabel = UILabel(frame: CGRectMake(25, 60, 100, 20))
//        vacancyLabel.text = job.valueForKey("title") as? String
//        cell.contentView.addSubview(vacancyLabel)
        
        var companyLogo = UIImageView(frame: CGRectMake(5, 5, 140, 60))
        companyLogo.layer.contentsGravity = kCAGravityCenter
        companyLogo.contentMode = .ScaleAspectFit
        cell.contentView.addSubview(companyLogo)
        cell.contentView.layer.borderWidth = 0.5
        cell.contentView.layer.borderColor = UIColor.grayColor().CGColor
        
        if let logoFile = job.objectForKey("logo") as? PFFile {
            logoFile.getDataInBackgroundWithBlock({ (imageData: NSData!, error: NSError!) -> Void in
                let logoData = UIImage(data: imageData)
                companyLogo.image = logoData
                cell.setNeedsLayout()
            })
        }
        return cell
    }
    
    //MARK: - UICollectionViewDelegate methods
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedObject = jobsModel.jobsArray[indexPath.row] as PFObject
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("detailTableViewController") as DetailTableViewController
        let nav = UINavigationController(rootViewController: vc)
        vc.selectedObject = selectedObject
        showDetailViewController(nav, sender: self)
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout methods
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        return CGSizeMake(150, 80)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 6.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 6.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(6, 6, 6, 6)
    }
}