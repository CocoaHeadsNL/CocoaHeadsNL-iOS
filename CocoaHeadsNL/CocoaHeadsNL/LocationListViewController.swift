//
//  LocationListViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 10/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class LocationListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var cellIdentifier = "companyCollectionViewCellIdentifier"
    var companyModel = CompaniesModel()
    //var companies = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.registerClass(NSClassFromString("UICollectionViewCell"), forCellWithReuseIdentifier: cellIdentifier)
        
    }
    
    
    //MARK: - UICollectionViewDataSource methods
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return companyModel.companiesArray.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        
        var company = companyModel.companiesArray[indexPath.row] as PFObject
        
        var companyLabel = UILabel(frame: CGRectMake(115, 5, 180, 20))
        companyLabel.text = company.valueForKey("name") as? String
        cell.contentView.addSubview(companyLabel)
        
        var companyLogo = UIImageView(frame: CGRectMake(0, 5, 120, 70))
        companyLogo.layer.contentsGravity = kCAGravityCenter
        companyLogo.contentMode = .ScaleAspectFit
        cell.contentView.addSubview(companyLogo)
        cell.contentView.layer.borderWidth = 0.5
        cell.contentView.layer.borderColor = UIColor.grayColor().CGColor
        
        if let logoFile = company.objectForKey("logo") as? PFFile {
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
        let selectedObject = companyModel.companiesArray[indexPath.row] as PFObject
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("detailTableViewController") as DetailTableViewController
        let nav = DetailNavigationController(rootViewController: vc)
        vc.selectedObject = selectedObject
        nav.selectedObject = selectedObject
        showDetailViewController(nav, sender: self)
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout methods
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        return CGSizeMake(310, 80)
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout methods
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }

}
