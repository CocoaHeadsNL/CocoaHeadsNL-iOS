//
//  LocationListViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 10/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class LocationListViewController: UICollectionViewController {
    
    var cellIdentifier = "companyCollectionViewCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.registerClass(NSClassFromString("UICollectionViewCell"), forCellWithReuseIdentifier: cellIdentifier)
        
    }
    
    
    //MARK - UICollectionViewDataSource methods
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        
        var companyLabel = UILabel(frame: CGRectMake(25, 60, 200, 20))
        companyLabel.text = "Stichting CocoaHeadsNL"
        cell.contentView.addSubview(companyLabel)
        
        var companyLogo = UIImageView(frame: CGRectMake(5, 5, 140, 50))
        companyLogo.layer.contentsGravity = kCAGravityCenter
        companyLogo.contentMode = .ScaleAspectFit
        companyLogo.image = UIImage(named: "CocoaHeads")
        cell.contentView.addSubview(companyLogo)
        
        cell.backgroundColor = UIColor.grayColor()
        
        return cell
    }
    
    //MARK - UICollectionViewDelegate methods
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedObject = collectionView.cellForItemAtIndexPath(indexPath)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("detailViewController") as DetailViewController
        //vc.selectedObject = selectedObject
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK - UICollectionViewDelegateFlowLayout methods
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        return CGSizeMake(300, 80)
    }
}
