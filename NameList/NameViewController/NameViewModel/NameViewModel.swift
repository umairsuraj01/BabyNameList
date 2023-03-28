//
//  NameViewModel.swift
//  NameList
//
//  Created by Muhammad Soorage on 23/03/2023.
//

import Foundation
import Combine

class NameViewModel {
    enum Input {
        case viewDidAppear
        case refreshButtonDidTap
        case genderButtonDidTap
        case filterValueDidChange
    }
    
    enum Output {
        case fetchNameDidFail(error :Error)
        case fetchNameDidSucceed(name: NameList)
        case toggleButton(isEnabled: Bool)
        case reloadNameData
    }
    
    var nameListArray: [NameList] = []
    var ethnicityArray: [NameList] = []
    var selectedEthnicity: NameList?
    var selectedGender: String = "MALE"
    private let output: PassthroughSubject<Output, Never> = .init()
    private let babyNameType: BabyNameType
    private var cancellables = Set<AnyCancellable>()
    
    init(babyNameType: BabyNameType = BabyName()) {
        self.babyNameType = babyNameType
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { event in
            switch event {
            case.refreshButtonDidTap, .viewDidAppear, .genderButtonDidTap:
                self.handleGetName()
            case.filterValueDidChange:
                self.updateValuesForFilter()
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    func updateView(_ nameList: [NameList]) {
        guard nameList.count > 0 else {
            return
        }
        self.nameListArray = nameList
        let uniqueElement = nameListArray.reduce(into: [String: NameList]()) { dict, babyName in
            dict[babyName.ethnicity] = babyName
        }.values.sorted(by: {$0.ethnicity < $1.ethnicity})
        self.ethnicityArray = uniqueElement
        self.output.send(.reloadNameData)
        
    }
    
    func updateValuesForFilter()  {
        let nameList = filterData(selectedGender, nameListArray, ethnicity: selectedEthnicity?.ethnicity ?? "").randomElement()
        if nameList != nil {
            self.output.send(.fetchNameDidSucceed(name: nameList!))
        }
    }
    
    func filterData(_ filterStr: String, _ names: [NameList], ethnicity: String) -> [NameList] {
        return names.filter {
            ($0.gender.lowercased() == filterStr.lowercased())
            && (ethnicity.isEmpty == false
                && $0.ethnicity.lowercased() == ethnicity.lowercased())
        }
    }
    
    private func handleGetName() {
        output.send(.toggleButton(isEnabled: false))
        babyNameType.getNameFromServer().sink { completion in
            self.output.send(.toggleButton(isEnabled: true))
            if case .failure(let error) = completion {
                self.output.send(.fetchNameDidFail(error: error))
            }
        } receiveValue: { name in
            self.updateView(name)
        }.store(in: &cancellables)
        
    }
}
