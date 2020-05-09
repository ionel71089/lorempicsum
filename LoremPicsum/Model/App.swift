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
    let imagePageLoader: ImagePageDatasource
    let imageRepository: ImageRepository
    let thumbnailDownloader: ThumbnailDownloader
    var fullImageCache = ImageCache()

    init(container: NSPersistentContainer) {
        imageRepository = ImageRepository(container: container)
        loremPicsumService = LoremPicsumService(network: network, itemsPerPage: 10)
        imagePageLoader = ImagePageDatasource(service: loremPicsumService, repository: imageRepository)
        thumbnailDownloader = ThumbnailDownloader(network: network)

        thumbnailDownloader.thumbnailStorage = imageRepository
    }

    var fullImageDownloader: FullImageDownloader {
        FullImageDownloader(cache: fullImageCache, network: network)
    }

    func detailsViewController(for image: Image, withCoder coder: NSCoder) -> DetailViewController? {
        return DetailViewController(coder: coder, image: image, downloader: fullImageDownloader)
    }
}
