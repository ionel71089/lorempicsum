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
        guard future == nil else { return }

        future = service
            .getPage(nextPage)
            .map(savePics)
            .onSuccess { images in
                if images.count == self.service.itemsPerPage {
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

    private func savePics(pics: [Pic]) -> [Image] {
        let count = repository.count
        let images = pics.enumerated().map { order, pic in
            repository.insert(pic: pic, order: count + order)
        }

        repository.save()

        return images.compactMap { $0 }
    }
}
