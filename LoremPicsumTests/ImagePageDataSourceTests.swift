//
//  ImagePageDataSourceTests.swift
//  LoremPicsumTests
//
//  Created by Ionel Lescai on 07/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

@testable import LoremPicsum
import XCTest

class ImagePageDataSourceTests: XCTestCase {
    lazy var mockPersistantContainer = self.createInMemoryContainer()
    lazy var pics = self.loadPics()

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testEmptyLoadsNextPage() {
        let service = MockService(pics: pics)
        let repo = ImageRepository(container: mockPersistantContainer)
        let sut = ImagePageDatasource(service: service,
                                      repository: repo)

        let xp = expectation(description: "wait for page to load")
        sut.onPageLoaded = {
            xp.fulfill()
        }

        wait(for: [xp], timeout: 1)

        XCTAssertEqual(service.requestedPage, 1)
        XCTAssertEqual(repo.count, 10)
        XCTAssertEqual(repo.fetchAll().map { $0.order }, Array(0 ..< 10))
        XCTAssertEqual(sut.nextPage, 2)
    }

    func loadAllPics(into repo: ImageRepository, count: Int = 10) {
        pics[0 ..< count].enumerated().forEach { order, pic in
            _ = repo.insert(pic: pic, order: order)
        }
        repo.save()
    }

    func testExistingDataDoesntLoadsNextPage() {
        let service = MockService(pics: [])
        let repo = ImageRepository(container: mockPersistantContainer)
        loadAllPics(into: repo)

        let sut = ImagePageDatasource(service: service,
                                      repository: repo)

        XCTAssertNil(service.requestedPage)
        XCTAssertEqual(sut.nextPage, 2)
    }

    func testLoadingNextPage() {
        let service = MockService(pics: pics.suffix(5), perPage: 5)
        let repo = ImageRepository(container: mockPersistantContainer)
        loadAllPics(into: repo, count: 5)

        let sut = ImagePageDatasource(service: service,
                                      repository: repo)

        sut.didViewItem(at: 3)

        let xp = expectation(description: "wait for page to load")
        sut.onPageLoaded = {
            xp.fulfill()
        }

        wait(for: [xp], timeout: 1)

        XCTAssertEqual(service.requestedPage, 2)
        XCTAssertEqual(sut.nextPage, 3)
        XCTAssertEqual(repo.fetchAll().map { $0.order }, Array(0 ..< 10))
    }

    func testLoadingLastPage() {
        let service = MockService(pics: [], perPage: 5)
        let repo = ImageRepository(container: mockPersistantContainer)
        loadAllPics(into: repo)

        let sut = ImagePageDatasource(service: service,
                                      repository: repo)

        sut.didViewItem(at: 7)

        let xp = expectation(description: "wait for page to load")
        sut.onPageLoaded = {
            xp.fulfill()
        }

        wait(for: [xp], timeout: 1)

        XCTAssertEqual(service.requestedPage, 3)
        XCTAssertEqual(sut.nextPage, 3)
    }

    func test_only_one_page_loading_at_a_time() {
        let service = MockService(pics: [], perPage: 5)
        let repo = ImageRepository(container: mockPersistantContainer)
        loadAllPics(into: repo)

        let sut = ImagePageDatasource(service: service,
                                      repository: repo)

        sut.didViewItem(at: 7)
        sut.didViewItem(at: 7)

        let xp = expectation(description: "wait for page to load")
        sut.onPageLoaded = {
            xp.fulfill()
            sut.onPageLoaded = nil
        }

        wait(for: [xp], timeout: 1)

        XCTAssertEqual(service.timesRequested, 1)
    }
}

class MockService: LoremPicsumServiceProtocol {
    var itemsPerPage: Int
    var pics: [Pic]
    var timesRequested = 0

    init(pics: [Pic], perPage: Int = 10) {
        self.pics = pics
        itemsPerPage = perPage
    }

    var requestedPage: Int?

    func getPage(_ page: Int) -> Future<[Pic]> {
        requestedPage = page
        timesRequested += 1
        defer { pics = Array(pics.dropFirst(itemsPerPage)) }
        return Future(resolved: Array(pics.prefix(itemsPerPage)))
    }
}
