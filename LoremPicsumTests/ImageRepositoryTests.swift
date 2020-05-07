//
//  ImageRepositoryTests.swift
//  LoremPicsumTests
//
//  Created by Ionel Lescai on 07/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

import XCTest
import CoreData
@testable import LoremPicsum

class ImageRepositoryTests: XCTestCase {
    lazy var mockPersistantContainer = self.createInMemoryContainer()
    lazy var pics = self.loadPics()

    var sut: ImageRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = ImageRepository(container: mockPersistantContainer)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testInsertOneItem() throws {
        let image = sut.insert(pic: pics[0], order: 0)
        XCTAssertEqual(image?.id, "0")
        XCTAssertEqual(image?.author, "Alejandro Escamilla")
        XCTAssertEqual(image?.downloadUrl, URL(string: "https://picsum.photos/id/0/5616/3744")!)
        XCTAssertEqual(image?.thumbnailUrl, URL(string: "https://picsum.photos/id/0/100")!)
        XCTAssertNil(image?.thumbnail)
        XCTAssertNil(image?.fileUrl)
    }

    func testFetchAll() {
        pics.enumerated().forEach { order, pic in
            _ = sut.insert(pic: pic, order: order)
        }

        sut.save()

        XCTAssertEqual(sut.fetchAll().count, pics.count)
    }
}
