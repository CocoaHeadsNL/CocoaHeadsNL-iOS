import UIKit
import CloudKit

class FetchAffiliateLinks {
    var apps = [AffiliateLink]()

    func fetchLinksForCompany(_ company: Company, completion: @escaping () -> Void) {
        if let recordName = company.recordName {

            let recordID = CKRecord.ID(recordName: recordName)
            let reference = CKRecord.Reference(recordID: recordID, action: .none)
            let pred = NSPredicate(format: "company == %@", reference)
            let refQuery = CKQuery(recordType: "AffiliateLinks", predicate: pred)
            let sort = NSSortDescriptor(key: "productName", ascending: false)
            refQuery.sortDescriptors = [sort]

            let operation = CKQueryOperation(query: refQuery)

            var affiliateLinks = [AffiliateLink]()

            let context = CoreDataStack.shared.persistentContainer.newBackgroundContext()
            operation.recordFetchedBlock = { (record) in
                let affLink = AffiliateLink.affiliateLink(forRecord: record, on: context)
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
