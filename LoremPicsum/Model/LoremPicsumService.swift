//
//  LoremPicsumService.swift
//  LoremPicsum
//
//  Created by Ionel Lescai on 07/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

import Foundation

protocol LoremPicsumServiceProtocol {
    var itemsPerPage: Int { get }
    func getPage(_ page: Int) -> Future<[Pic]>
}

class LoremPicsumService: LoremPicsumServiceProtocol {
    var network: NetworkDelegate
    let itemsPerPage: Int

    init(network: NetworkDelegate, itemsPerPage: Int) {
        self.network = network
        self.itemsPerPage = itemsPerPage
    }

    struct Pic: Decodable, Equatable {
        let id: String
        let width: Int
        let height: Int
        let downloadUrl: URL
        let author: String

        func thumbnailUrl(size: Int) -> URL {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "picsum.photos"
            urlComponents.path = "/id/\(id)/\(size)"
            return urlComponents.url!
        }
    }

    private func url(forPage page: Int) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "picsum.photos"
        urlComponents.path = "/v2/list"
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(itemsPerPage)"),
        ]
        return urlComponents.url!
    }

    func getPage(_ page: Int) -> Future<[Pic]> {
        network
            .getData(url: url(forPage: page), cancellationToken: nil)
            .flatMap(parse)
    }

    private func parse(data: Data) -> Future<[Pic]> {
        Future { completion, _ in
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let pics = try decoder.decode([Pic].self, from: data)
                completion(.success(pics))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
