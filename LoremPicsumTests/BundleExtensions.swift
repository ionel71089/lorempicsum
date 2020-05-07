//
//  BundleExtensions.swift
//  LoremPicsumTests
//
//  Created by Ionel Lescai on 07/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

import Foundation
import LoremPicsum
import XCTest

extension XCTestCase {
    func loadJsonData(_ fileName: String) -> Future<Data> {
        Future { completion, _ in
            do {
                if let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "json") {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
                    completion(.success(data))
                } else {
                    throw "File not found"
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
