//
//  Network.swift
//  LoremPicsum
//
//  Created by Ionel Lescai on 08/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

import Foundation

protocol NetworkDelegate {
    func getData(url: URL, cancellationToken: CancellationToken?) -> Future<Data>
}

class Network: NetworkDelegate {
    func getData(url: URL, cancellationToken: CancellationToken?) -> Future<Data> {
        Future(cancellationToken: cancellationToken) { completion, token in
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

            token?.onCanceled {
                task.cancel()
            }
        }
    }
}
