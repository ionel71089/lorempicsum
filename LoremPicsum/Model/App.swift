//
//  App.swift
//  LoremPicsum
//
//  Created by Ionel Lescai on 08/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

import CoreData

class App {
    static var shared: App!

    let network = Network()
    let loremPicsumService: LoremPicsumService
    let imagePageLoader: ImageDataSource
    let imageRepository: ImageRepository

    init(container: NSPersistentContainer) {
        imageRepository = ImageRepository(container: container)
        loremPicsumService = LoremPicsumService(network: network, itemsPerPage: 10)
        imagePageLoader = ImageDataSource(service: loremPicsumService, repository: imageRepository)
    }
}
