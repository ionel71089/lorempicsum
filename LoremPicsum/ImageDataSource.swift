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

    private var nextPage: Int

    init(service: LoremPicsumServiceProtocol,
         repository: ImageRepositoryProtocol) {
        self.service = service
        self.repository = repository

        let count = repository.count
        nextPage = count / service.itemsPerPage

        if count == 0 {

        }
    }

    private func loadNextPage() {

    }
}
