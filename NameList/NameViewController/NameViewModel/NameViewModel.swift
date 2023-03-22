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
    }
    
    enum Output {
        case fetchNameDidFail(error :Error)
        case fetchNameDidSucceed(name: [NameList])
        case toggleButton(isEnabled: Bool)
    }
    
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
                self.handleGetRandomName()
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    private func handleGetRandomName() {
        output.send(.toggleButton(isEnabled: false))
        babyNameType.getRandomNameFromJson().sink { completion in
            self.output.send(.toggleButton(isEnabled: true))
            if case .failure(let error) = completion {
                self.output.send(.fetchNameDidFail(error: error))
            }
        } receiveValue: { name in
            self.output.send(.fetchNameDidSucceed(name: name))
        }.store(in: &cancellables)
        
    }
}
