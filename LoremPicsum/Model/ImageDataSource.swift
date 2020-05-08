//
//  ImageDataSource.swift
//  LoremPicsum
//
//  Created by Ionel Lescai on 07/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

import Foundation

class ImageDataSource {
    let service: LoremPicsumServiceProtocol
    let repository: ImageRepositoryProtocol

    private(set) var nextPage: Int
    private var nextIndex: Int
    private var lastPage = false

    private var future: Future<[Image]>?

    init(service: LoremPicsumServiceProtocol,
         repository: ImageRepositoryProtocol) {
        self.service = service
        self.repository = repository

        let count = repository.count
        nextPage = 1 + count / service.itemsPerPage
        nextIndex = count - 3

        if count == 0 {
            _ = loadNextPage()
        }
    }

    private func loadNextPage() {
        guard future == nil, !lastPage else { return }

        future = service
            .getPage(nextPage)
            .flatMap(savePics)
            .onSuccess { images in
                if images.count > 0 {
                    self.nextPage += 1
                    self.nextIndex += images.count
                } else {
                    self.lastPage = true
                }
            }.onResult { _ in
                self.future = nil
            }
    }

    func didViewItem(at index: Int) {
        if index >= nextIndex {
            loadNextPage()
        }
    }

    private func savePics(pics: [Pic]) -> Future<[Image]> {
        let count = repository.count

        return Future(in: .userInteractive) { completion, _ in
            let images = pics.enumerated().map { order, pic in
                self.repository.insert(pic: pic, order: count + order)
            }

            self.repository.save()

            completion(.success(images.compactMap { $0 }))
        }
    }
}
