//
//  BabyName.swift
//  NameList
//
//  Created by Muhammad Soorage on 23/03/2023.
//

import Foundation
import Combine

protocol BabyNameType {
    func getNameFromServer() -> AnyPublisher<[NameList], Error>
}

class BabyName: BabyNameType {
    private let apiUrl = "https://data.cityofnewyork.us/api/views/25th-nujf/rows.json"
    private let fileName: String = "babyNames.json"
    //    func getNameFromServer() -> AnyPublisher<[NameList], Error> {
    //        return Bundle.main.readFile(file: fileName).decode(type: [[String]].self, decoder: JSONDecoder()).map { array in
    //            return array.map { innerArray in
    //                guard innerArray.count == 6 else {
    //                    fatalError("Unexpected number of elements in inner array")
    //                }
    //                return NameList(year: innerArray[0], gender: innerArray[1], ethnicity: innerArray[2], name: innerArray[3], count: innerArray[4], rank: innerArray[5])
    //            }
    //        }.mapError { error in
    //            return error
    //        }.eraseToAnyPublisher()
    //    }
    
    
    func getNameFromServer() -> AnyPublisher<[NameList], Error> {
        let url = URL(string: apiUrl)!
        return URLSession.shared.dataTaskPublisher(for: url)
            .catch { error in
                return Fail(error: error).eraseToAnyPublisher()
            }.map({ $0.data })
            .tryMap{ data -> [String: Any?] in
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any?] else {
                    throw URLError(.badServerResponse)
                }
                return json
            }
            .map { response -> [NameList] in
                let node = (response as AnyObject)["data"] as? [Any?]
                return node?.compactMap{ nameValues -> NameList? in
                    guard let values = nameValues as? [Any] else { return nil }
                    let year = values[8] as? String ?? ""
                    let gender = values[9] as? String ?? ""
                    let ethnicity = values[10] as? String ?? ""
                    let name = values[11] as? String ?? ""
                    let count = values[12] as? String ?? ""
                    let rank = values[13] as? String ?? ""
                    return NameList(year: year, gender: gender, ethnicity: ethnicity, name: name, count: count, rank: rank)
                } ?? []
            }
            .mapError{ error in
                return error
            }.eraseToAnyPublisher()
    }
}
