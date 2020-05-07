//
//  Mocking.swift
//  LoremPicsumTests
//
//  Created by Ionel Lescai on 07/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

import CoreData
import XCTest
@testable import LoremPicsum

extension XCTestCase {
    func createInMemoryContainer() -> NSPersistentContainer {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))])!
        let container = NSPersistentContainer(name: "LoremPicsum", managedObjectModel: managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false

        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { description, error in
            precondition(description.type == NSInMemoryStoreType)

            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        return container
    }

    func loadPics() -> [LoremPicsumService.Pic] {
        let path = Bundle(for: type(of: self)).path(forResource: "firstPage", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let pics = try! decoder.decode([Pic].self, from: data)
        return pics
    }
}
