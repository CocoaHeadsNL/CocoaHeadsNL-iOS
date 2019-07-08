//
//  CoreDataStack.swift
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 08/07/2019.
//  Copyright © 2019 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                print("Unable to Load Persistent Store")
                print("\(error), \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    var newBackgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
}
