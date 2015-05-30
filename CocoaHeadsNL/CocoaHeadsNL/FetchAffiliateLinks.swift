import UIKit

class FetchAffiliateLinks {
    var apps = [AffiliateLink]()

    func fetchLinksForCompany(company: Company, completion: () -> Void) {
        if let objectID = company.objectId {
            let affiliateQuery = PFQuery(className: "affiliateLinks")
            affiliateQuery.whereKey("company", equalTo: PFObject(withoutDataWithClassName: "Companies", objectId: objectID))
            affiliateQuery.cachePolicy = PFCachePolicy.CacheElseNetwork

            affiliateQuery.findObjectsInBackgroundWithBlock { objects, error in
                if error != nil {
                    println("Error: \(error!) \(error!.userInfo!)")
                    return
                }

                //println("Successfully retrieved \(objects!.count) objects.")

                if let objects = objects as? [AffiliateLink] {
                    self.apps = objects
                    completion()
                }
            }
        }
    }
}
