//
//  NameViewController.swift
//  NameList
//
//  Created by Muhammad Soorage on 23/03/2023.
//

import UIKit
import Combine

class NameViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var ethnicityLabel: UILabel?
    @IBOutlet weak var yearLabel: UILabel?
    @IBOutlet weak var genderLabel: UILabel?
    @IBOutlet weak var countLabel: UILabel?
    @IBOutlet weak var rankLabel: UILabel?
    @IBOutlet weak var maleButton: UIButton?
    @IBOutlet weak var femaleButton: UIButton?
    @IBOutlet weak var refreshButton: UIButton?
    private let nameViewModel = NameViewModel()
    private let input: PassthroughSubject<NameViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.send(.viewDidAppear)
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        input.send(.refreshButtonDidTap)
    }
    
    @IBAction func genderButtonTapped(_ sender: Any) {
        if (sender as? UIButton)?.isSelected == false {
            toggleGenderSelection(sender as! UIButton)
            input.send(.genderButtonDidTap)
        }
    }
    
    func toggleGenderSelection(_ currentButton: UIButton) {
        currentButton.isSelected = true
        if currentButton.tag == 0 {
            femaleButton?.isSelected = false
        }
        else {
            maleButton?.isSelected = false
        }
    }
    
    private func bind() {
        let output = nameViewModel.transform(input: input.eraseToAnyPublisher())
        output.receive(on: DispatchQueue.main)
            .sink { event in
                switch event {
                case .fetchNameDidFail(let error):
                    self.nameLabel?.text = error.localizedDescription
                case .fetchNameDidSucceed(let names):
                    let gender = self.selectedGender()
                    let nameList = self.filterData(gender, names).randomElement()!
                    self.displayNameData(nameList)
                case .toggleButton(let isEnabled):
                    self.refreshButton?.isEnabled = isEnabled
                }
            }.store(in: &cancellables)
    }
    
    func displayNameData(_ nameData: NameList) {
        self.nameLabel?.text = nameData.name
        self.ethnicityLabel?.text = nameData.ethnicity
        self.yearLabel?.text = nameData.year
        self.genderLabel?.text = nameData.gender
        self.countLabel?.text = nameData.count
        self.rankLabel?.text = nameData.rank
    }
    
    func filterData(_ filterStr: String, _ names: [NameList]) -> [NameList] {
        return names.filter {$0.gender.lowercased() == filterStr.lowercased()}
    }
    
    func selectedGender() -> String {
        if self.maleButton?.isSelected == true {
            return (self.maleButton?.titleLabel?.text)!
        }
        return (self.femaleButton?.titleLabel?.text)!
    }
}
