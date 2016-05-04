import UIKit
import CloudKit

class FetchAffiliateLinks {
    var apps = [AffiliateLink]()

    func fetchLinksForCompany(company: Company, completion: () -> Void) {
        if let recordID = company.recordID {
            
            //check if we get the correct string back as id
            //print(recordID.recordName)
            
            let reference = CKReference(recordID: recordID, action: .None)
            let pred = NSPredicate(format: "company == %@", reference)
            let refQuery = CKQuery(recordType: "AffiliateLinks", predicate: pred)
            let sort = NSSortDescriptor(key: "productName", ascending: false)
            refQuery.sortDescriptors = [sort]
            
            let operation = CKQueryOperation(query: refQuery)
            
            var CKAffiliateLink = [AffiliateLink]()
            
            operation.recordFetchedBlock = { (record) in
                let affLink = AffiliateLink()
                
                affLink.affiliateId = record["affiliateId"] as? String
                affLink.productName = record["productName"] as? String
                affLink.productCreator = record["productCreator"] as? String
                affLink.company = record["company"] as? CKReference
                
                CKAffiliateLink.append(affLink)
            }
            
            operation.queryCompletionBlock = { [unowned self] (cursor, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    if error == nil {
                        
                        self.apps = CKAffiliateLink
                        completion()
                    }
                }
            }
            
            CKContainer.defaultContainer().publicCloudDatabase.addOperation(operation)
        }
    }
}
