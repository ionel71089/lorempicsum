//
//  ImageDataSourceTests.swift
//  LoremPicsumTests
//
//  Created by Ionel Lescai on 07/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

@testable import LoremPicsum
import XCTest

class ImageDataSourceTests: XCTestCase {
    lazy var mockPersistantContainer = self.createInMemoryContainer()
    lazy var pics = self.loadPics()

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testEmptyLoadsNextPage() {
        let service = MockService()
        let repo = MockRepository(count: 0)
        let sut = ImageDataSource(service: service,
                                  repository: repo)
    }
}

class MockService: LoremPicsumServiceProtocol {
    var itemsPerPage: Int = 10

    var requestedPage: Int?

    func getPage(_ page: Int) -> Future<[Pic]> {
    }
}

class MockRepository: ImageRepositoryProtocol {
    private(set) var count: Int

    init(count: Int) {
        self.count = count
    }

    func insert(pic: Pic, order: Int) -> Image? {
        return nil
    }

    func fetchAll() -> [Image] {
        return []
    }

    func save() {
    }
}
