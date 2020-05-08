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
    let thumbnailDownloader: ThumbnailDownloader
    var fullImageCache = ImageCache()
    let fullImageDownloader: FullImageDownloader

    init(container: NSPersistentContainer) {
        imageRepository = ImageRepository(container: container)
        loremPicsumService = LoremPicsumService(network: network, itemsPerPage: 10)
        imagePageLoader = ImageDataSource(service: loremPicsumService, repository: imageRepository)
        thumbnailDownloader = ThumbnailDownloader(network: network)

        thumbnailDownloader.thumbnailStorage = imageRepository
        fullImageDownloader = FullImageDownloader(cache: fullImageCache)
    }

    func detailsViewController(for image: Image, withCoder coder: NSCoder) -> DetailViewController? {
        return DetailViewController(coder: coder, image: image, downloader: fullImageDownloader)
    }
}
