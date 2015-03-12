//
//  JobsViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 07/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit

class JobsViewController: UICollectionViewController
{
    var cellIdentifier = "jobsCollectionViewCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.registerClass(NSClassFromString("UICollectionViewCell"), forCellWithReuseIdentifier: cellIdentifier)

    }
    
    
    //MARK: - UICollectionViewDataSource methods
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        
        var vacancyLabel = UILabel(frame: CGRectMake(25, 60, 100, 20))
        vacancyLabel.text = "iOS engineer"
        cell.contentView.addSubview(vacancyLabel)
        
        var companyLogo = UIImageView(frame: CGRectMake(5, 5, 140, 60))
        companyLogo.layer.contentsGravity = kCAGravityCenter
        companyLogo.contentMode = .ScaleAspectFit
        companyLogo.image = UIImage(named: "CocoaHeads")
        cell.contentView.addSubview(companyLogo)
        
        //testing purposes otherwise cant see cell
        cell.backgroundColor = UIColor.lightGrayColor()
        
        return cell
    }
    
    //MARK: - UICollectionViewDelegate methods
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedObject = collectionView.cellForItemAtIndexPath(indexPath)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("detailViewController") as DetailViewController
        //vc.selectedObject = selectedObject
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout methods
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        return CGSizeMake(150, 80)
    }
    
    
}