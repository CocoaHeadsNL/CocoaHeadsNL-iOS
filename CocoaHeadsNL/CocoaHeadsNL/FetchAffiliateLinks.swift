import UIKit
import CloudKit

class FetchAffiliateLinks {
    var apps = [AffiliateLink]()

    func fetchLinksForCompany(company: Company, completion: () -> Void) {
        if let recordID = company.recordID {

            let reference = CKReference(recordID: recordID, action: .None)
            let pred = NSPredicate(format: "company == %@", reference)
            let refQuery = CKQuery(recordType: "AffiliateLinks", predicate: pred)
            let sort = NSSortDescriptor(key: "productName", ascending: false)
            refQuery.sortDescriptors = [sort]

            let operation = CKQueryOperation(query: refQuery)

            var affiliateLinks = [AffiliateLink]()

            operation.recordFetchedBlock = { (record) in
                let affLink = AffiliateLink(record: record)
                affiliateLinks.append(affLink)
            }

            operation.queryCompletionBlock = { [unowned self] (cursor, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    if error == nil {

                        self.apps = affiliateLinks
                        completion()
                    }
                }
            }

            CKContainer.defaultContainer().publicCloudDatabase.addOperation(operation)
        }
    }
}
