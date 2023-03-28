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
    @IBOutlet weak var ethnicityPickerView: UIPickerView?
    
    
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
            input.send(.filterValueDidChange)
        }
    }
    
    func toggleGenderSelection(_ currentButton: UIButton) {
        currentButton.isSelected = true
        if currentButton.tag == 0 {
            femaleButton?.isSelected = false
            nameViewModel.selectedGender = (self.maleButton?.titleLabel?.text)!
        }
        else {
            maleButton?.isSelected = false
            nameViewModel.selectedGender = (self.femaleButton?.titleLabel?.text)!
        }
    }
    
    private func bind() {
        let output = nameViewModel.transform(input: input.eraseToAnyPublisher())
        output.receive(on: DispatchQueue.main)
            .sink { event in
                switch event {
                case .fetchNameDidFail(let error):
                    self.nameLabel?.text = error.localizedDescription
                case .fetchNameDidSucceed(let name):
                    self.displayNameData(name)
                case .reloadNameData:
                    self.reloadData()
                case .toggleButton(let isEnabled):
                    self.refreshButton?.isEnabled = isEnabled
                }
            }.store(in: &cancellables)
    }
    
    func reloadData() {
        self.ethnicityPickerView?.reloadAllComponents()
        let selectedIndex = self.ethnicityPickerView?.selectedRow(inComponent: 0)
        nameViewModel.selectedEthnicity = nameViewModel.ethnicityArray[selectedIndex ?? 0]
        input.send(.filterValueDidChange)
    }
    
    func displayNameData(_ nameData: NameList) {
        self.nameLabel?.text = nameData.name
        self.ethnicityLabel?.text = nameData.ethnicity
        self.yearLabel?.text = nameData.year
        self.genderLabel?.text = nameData.gender
        self.countLabel?.text = nameData.count
        self.rankLabel?.text = nameData.rank
    }
}

extension NameViewController: UIPickerViewAccessibilityDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return nameViewModel.ethnicityArray.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return nameViewModel.ethnicityArray[row].ethnicity
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        nameViewModel.selectedEthnicity = nameViewModel.ethnicityArray[row]
        input.send(.filterValueDidChange)
    }
}
