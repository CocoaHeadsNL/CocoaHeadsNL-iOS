import UIKit

class FetchAffiliateLinks {
    var apps = [AffiliateLink]()

    func fetchLinksForCompany(company: Company, completion: () -> Void) {
        if let objectID = company.objectId {
            let affiliateQuery = AffiliateLink.query()!
            affiliateQuery.whereKey("company", equalTo: PFObject(withoutDataWithClassName: Company.parseClassName(), objectId: objectID))
            affiliateQuery.cachePolicy = PFCachePolicy.CacheThenNetwork

            affiliateQuery.findObjectsInBackgroundWithBlock { objects, error in
                if error != nil {
                    print("Error: \(error!) \(error!.userInfo)")
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
