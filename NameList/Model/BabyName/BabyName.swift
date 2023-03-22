//
//  BabyName.swift
//  NameList
//
//  Created by Muhammad Soorage on 23/03/2023.
//

import Foundation
import Combine

protocol BabyNameType {
    func getRandomNameFromJson() -> AnyPublisher<[NameList], Error>
}

class BabyName: BabyNameType {
    private let fileName: String = "babyNames.json"
    func getRandomNameFromJson() -> AnyPublisher<[NameList], Error> {
        return Bundle.main.readFile(file: fileName).decode(type: [[String]].self, decoder: JSONDecoder()).map { array in
            return array.map { innerArray in
                guard innerArray.count == 6 else {
                    fatalError("Unexpected number of elements in inner array")
                }
                return NameList(year: innerArray[0], gender: innerArray[1], ethnicity: innerArray[2], name: innerArray[3], count: innerArray[4], rank: innerArray[5])
            }
        }.mapError { error in
            return error
        }.eraseToAnyPublisher()
    }
}
