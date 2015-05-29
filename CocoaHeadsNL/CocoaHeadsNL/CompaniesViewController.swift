//
//  CompaniesViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 10/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class CompaniesViewController: PFQueryCollectionViewController, UICollectionViewDelegateFlowLayout {
    override func queryForCollection() -> PFQuery {
        let query = Company.query()
        query!.cachePolicy = .CacheThenNetwork
        return query!
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    }

    //MARK: - UICollectionViewDataSource methods

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell {
        if let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath, object: object) {
            let company = object as? Company

            let logoWidth: CGFloat = 120

            if let companyLogo = company?.logo {
                cell.imageView.file = companyLogo
                cell.imageView.frame = CGRect(x: 0, y: 5, width: logoWidth, height: 70)
                cell.imageView.image = UIImage(named: "CocoaHeadsNLLogo")
                cell.imageView.loadInBackground(nil)
            }

            let whiteSpace: CGFloat = 10
            let labelWidth = cell.bounds.width - whiteSpace - logoWidth

            cell.textLabel.numberOfLines = 2
            cell.textLabel.frame = CGRect(x: logoWidth + whiteSpace, y: 5, width: labelWidth, height: 70)
            cell.textLabel.text = company?.name

            cell.contentView.layer.borderWidth = 0.5
            cell.contentView.layer.borderColor = UIColor.grayColor().CGColor
            
            return cell
        }
        fatalError("Could not get a cell")
    }

    //MARK: - UICollectionViewDelegate methods

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowDetail", sender: collectionView.cellForItemAtIndexPath(indexPath))
    }

    //MARK: - UICollectionViewDelegateFlowLayout methods

    override func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width - 10, height: 80)
    }

    //MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            if let indexPath = self.collectionView?.indexPathForCell(sender as! UICollectionViewCell) {
                let company = self.objectAtIndexPath(indexPath) as! Company
                let dataSource = CompanyDataSource(object: company)
                dataSource.fetchAffiliateLinks()

                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.dataSource = dataSource
            }
        }
    }
}
