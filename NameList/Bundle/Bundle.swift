//
//  Bundle.swift
//  NameList
//
//  Created by Muhammad Soorage on 23/03/2023.
//

import Foundation
import Combine

extension Bundle {
    //baby_names_info
    func readFile(file: String) -> AnyPublisher<Data, Error> {
        self.url(forResource: file, withExtension: nil).publisher.tryMap { string in
            guard let data = try? Data(contentsOf: string) else {
                fatalError("Failed to load from bundle with file path \(file)")
            }
            return data
        }.mapError { error in
            return error
        }.eraseToAnyPublisher()
    }
}
