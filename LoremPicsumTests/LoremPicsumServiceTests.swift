//
//  LoremPicsumServiceTests.swift
//  LoremPicsumTests
//
//  Created by Ionel Lescai on 07/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

@testable import LoremPicsum
import XCTest

class LoremPicsumServiceTests: XCTestCase {
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testItCallsNetworkWithCorrectURL() {
        let network = MockNetwork(future: Future(resolved: Data()))
        let sut = LoremPicsumService(network: network, itemsPerPage: 10)
        let xp = expectation(description: "It should resolve")

        sut.getPage(1).onResult { result in
            xp.fulfill()
        }

        wait(for: [xp], timeout: 1.0)

        XCTAssertEqual(network.calledURL, URL(string: "https://picsum.photos/v2/list?page=1&limit=10")!)
    }

    func testItParsesResponse() {
        let network = MockNetwork(future: loadJsonData("firstPage"))
        let sut = LoremPicsumService(network: network, itemsPerPage: 10)
        let xp = expectation(description: "It should resolve")

        sut.getPage(1).onResult { result in
            let pics = try? result.get()
            XCTAssertEqual(pics?.count, 10)
            let pic = pics?[0]

            XCTAssertEqual(pic?.id, "0")
            XCTAssertEqual(pic?.width, 5616)
            XCTAssertEqual(pic?.height, 3744)
            XCTAssertEqual(pic?.downloadUrl, URL(string: "https://picsum.photos/id/0/5616/3744")!)
            XCTAssertEqual(pic?.author, "Alejandro Escamilla")

            XCTAssertEqual(pic?.thumbnailUrl(size: 200), URL(string: "https://picsum.photos/id/0/200")!)

            xp.fulfill()
        }

        wait(for: [xp], timeout: 1.0)
    }

    func testItErrorsOnInvalidJson() {
        let network = MockNetwork(future: Future(resolved:
            String("InvalidJson").data(using: .utf8)!))
        let sut = LoremPicsumService(network: network, itemsPerPage: 10)
        let xp = expectation(description: "It should resolve")

        sut.getPage(1).onError { error in
            xp.fulfill()
        }

        wait(for: [xp], timeout: 1.0)
    }
}

class MockNetwork: NetworkDelegate {
    var future: Future<Data>
    var calledURL: URL?

    init(future: Future<Data>) {
        self.future = future
    }

    func getData(url: URL, cancellationToken: CancellationToken?) -> Future<Data> {
        self.calledURL = url
        return future
    }
}
