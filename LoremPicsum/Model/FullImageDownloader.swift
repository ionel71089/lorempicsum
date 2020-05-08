//
//  FullImageDownloader.swift
//  LoremPicsum
//
//  Created by Ionel Lescai on 08/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

import UIKit

class FullImageDownloader {
    var imageCache: ImageCache

    init(cache: ImageCache) {
        imageCache = cache
    }

    func getImage(url: URL) -> Future<UIImage> {
        getImageFromCache(url: url)
            .recover { _ in
                self.loadImage(url: url)
            }
            .recover { _ in
                self.downloadImage(url: url)
                    .flatMap(self.saveImage(url: url))
            }.onSuccess { image in
                self.imageCache[url.absoluteString] = image
            }
    }

    private func loadImage(url: URL) -> Future<UIImage> {
        let path = filePath(forUrl: url)
        return Future { completion, _ in
            let image = path
                .flatMap({ try? Data(contentsOf: $0) })
                .flatMap({ UIImage(data: $0) })
            if let image = image {
                completion(.success(image))
            } else {
                completion(.failure("Failed to load image"))
            }
        }
    }

    private func getImageFromCache(url: URL) -> Future<UIImage> {
        Future { completion, _ in
            if let image = self.imageCache[url.absoluteString] {
                completion(.success(image))
            } else {
                completion(.failure("Cache miss"))
            }
        }
    }

    private func downloadImage(url: URL) -> Future<(Data, UIImage)> {
        Future(in: .background) { completion, _ in
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    completion(.success((data, image)))
                } else {
                    throw "Loading image from data failed"
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func filePath(forUrl url: URL) -> URL? {
        FileManager
            .default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(url.path.replacingOccurrences(of: "/", with: ""))
    }

    private func saveImage(url: URL) -> (_ data: Data, _ image: UIImage) -> Future<UIImage> {
        let path = filePath(forUrl: url)

        return { data, image in
            Future(in: .background) { completion, _ in
                do {
                    if let path = path {
                        try data.write(to: path)
                        completion(.success(image))
                    } else {
                        throw "Path failed"
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
