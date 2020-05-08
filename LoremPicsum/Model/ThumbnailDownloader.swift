//
//  ThumbnailDownloader.swift
//  LoremPicsum
//
//  Created by Ionel Lescai on 08/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

import UIKit
import CoreData

class ThumbnailDownloader {
    let cache = ImageCache()
    let network: NetworkDelegate
    var futures = [String: Future<UIImage>]()
    weak var thumbnailStorage: ThumbnailStorage?

    init(network: NetworkDelegate) {
        self.network = network
    }

    func getThumbnail(forModel model: Image) -> (UIImage?, Future<UIImage>?) {
        let id = model.id!
        let objectId = model.objectID
        var image = cache[id]

        if image == nil, let storedImage = model.thumbnail.flatMap({ UIImage(data: $0) }) {
            image = storedImage
            cache[id] = storedImage
        }

        var future: Future<UIImage>?
        let url = model.thumbnailUrl!

        if image == nil {
            future = (futures[id] ?? downloadImage(url: url, objectId: objectId))
            .onSuccess { image in
                self.cache[id] = image
            }
            .onResult { _ in
                self.futures[id] = nil
            }

            futures[id] = future
        }

        return (image, future)
    }

    func downloadImage(url: URL, objectId: NSManagedObjectID) -> Future<UIImage> {
        Future(in: .userInteractive) { [weak self] completion, _ in
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    let blurredImage = image.addFilter(filter: .Fade)
                    if let blurredData = blurredImage.pngData() {
                        self?.thumbnailStorage?.addThumbnail(data: blurredData, forModelWithId: objectId)
                    }
                    completion(.success(blurredImage))
                } else {
                    throw "Loading image from data failed"
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
