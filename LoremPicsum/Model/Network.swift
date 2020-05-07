//
//  Network.swift
//  LoremPicsum
//
//  Created by Ionel Lescai on 08/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

import Foundation

class Network: NetworkDelegate {
    func getJsonData(url: URL) -> Future<Data> {
        Future { completion, _ in
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, error == nil {
                    completion(.success(data))
                } else if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure("Unknown error"))
                }
            }
            task.resume()
        }
    }
}
