//
//  ImageRepository.swift
//  LoremPicsum
//
//  Created by Ionel Lescai on 07/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

import CoreData
import Foundation

typealias Pic = LoremPicsumService.Pic

protocol ImageRepositoryProtocol {
    func insert(pic: Pic, order: Int) -> Image?
    func fetchAll() -> [Image]
    func save()

    var count: Int { get }
}

class ImageRepository: ImageRepositoryProtocol {
    let persistentContainer: NSPersistentContainer!

    init(container: NSPersistentContainer) {
        persistentContainer = container
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    lazy var backgroundContext: NSManagedObjectContext = {
        self.persistentContainer.newBackgroundContext()
    }()

    func insert(pic: Pic, order: Int) -> Image? {
        guard let image = NSEntityDescription.insertNewObject(forEntityName: "Image",
                                                              into: backgroundContext) as? Image else {
            return nil
        }

        image.id = pic.id
        image.author = pic.author
        image.downloadUrl = pic.downloadUrl
        image.thumbnailUrl = pic.thumbnailUrl(size: 100)
        image.order = Int64(order)

        return image
    }

    func fetchAll() -> [Image] {
        let request: NSFetchRequest<Image> = Image.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        let results = try? persistentContainer.viewContext.fetch(request)
        return results ?? [Image]()
    }

    var count: Int {
        let request: NSFetchRequest<Image> = Image.fetchRequest()
        return (try? persistentContainer.viewContext.count(for: request)) ?? 0
    }

    func save() {
        if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
                print("Save error \(error)")
            }
        }
    }
}
