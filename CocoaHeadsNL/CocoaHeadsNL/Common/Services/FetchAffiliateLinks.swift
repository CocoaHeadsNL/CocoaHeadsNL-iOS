import UIKit
import CloudKit

class FetchAffiliateLinks {
    var apps = [AffiliateLink]()

    func fetchLinksForCompany(_ company: Company, completion: @escaping () -> Void) {
        if let recordName = company.recordName {

            let recordID = CKRecordID(recordName: recordName)
            let reference = CKReference(recordID: recordID, action: .none)
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

            operation.queryCompletionBlock = { [weak self] (cursor, error) in
                DispatchQueue.main.async {
                    if error == nil {

                        self?.apps = affiliateLinks
                        completion()
                    }
                }
            }

            CKContainer.default().publicCloudDatabase.add(operation)
        }
    }
}
