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
  public var agency: Agency? {
    didSet {
      fill()
    }
  }
  lazy var googleClient: GoogleClientRequest = GoogleClient()
  
  override func viewDidLoad() {
    verifyAgency()
    super.viewDidLoad()
  }
}


extension AgencyViewController {
  
  func verifyAgency() {
    guard let agency = agency else { return }
    
    //Show cached agency first and them, fetch the values
    AgencyAdapter.getAgency(placeId: agency.placeID) { (agency) in
      guard let agency = agency else {
        self.fetchAgencyDetails()
        return
      }
      self.agency = agency
      self.fetchAgencyDetails()
    }
  }
  
  func fill() {
    DispatchQueue.main.async {
      self.nameLabel.text = self.agency?.name ?? ""
      self.openHoursLabel.text = self.agency?.openingHours?.joined(separator: "\n") ?? ""
      self.phoneNumberLabel.text = self.agency?.phoneNumber ?? ""
    }
  }
  
  func fetchAgencyDetails() {
    guard let agency = agency else { return }
    googleClient.getGooglePlaceDetails(placeID: agency.placeID) { (response) in
      AgencyAdapter.updateIfNeed(agency: agency, details: response.result)
      AgencyAdapter.saveAgency(agency)
      self.fill()
    }
  }
}
