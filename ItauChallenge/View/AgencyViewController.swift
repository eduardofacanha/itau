//
//  AgencyViewController.swift
//  ItauChallenge
//
//  Created by Eduardo Façanha on 01/12/19.
//  Copyright © 2019 Eduardo Façanha. All rights reserved.
//

import UIKit

class AgencyViewController: UIViewController {
  
  @IBOutlet weak private var nameLabel: UILabel!
  @IBOutlet weak private var openHoursLabel: UITextView!
  @IBOutlet weak private var phoneNumberLabel: UILabel!
  
  private(set) var viewModel = AgencyDetailsViewModel()

  override func viewDidLoad() {
    viewModel.setDelegate(self)
    super.viewDidLoad()
  }
}

extension AgencyViewController: AgencyDetailsViewModelDelegate {
  func connectionError() {
    let alertController = UIAlertController.init(title: "Network connection failed",
                                                 message: "Check your connection and try again", preferredStyle: .alert)
    alertController.addAction(.init(title: "ok", style: .default, handler: nil))
    DispatchQueue.main.async {
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  func fill() {
    DispatchQueue.main.async {
      self.nameLabel.text = self.viewModel.name
      self.openHoursLabel.text = self.viewModel.openingHours
      self.phoneNumberLabel.text = self.viewModel.phoneNumberLabel
    }
  }
}

