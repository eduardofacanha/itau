//
//  AgencyDetailsViewModel.swift
//  ItauChallenge
//
//  Created by Eduardo Façanha on 01/12/19.
//  Copyright © 2019 Eduardo Façanha. All rights reserved.
//

import UIKit

protocol AgencyDetailsViewModelDelegate {
  func fill()
}

class AgencyDetailsViewModel: NSObject {
  lazy var googleClient: GoogleClientRequest = GoogleClient()
  private var agency: Agency? {
    didSet {
      delegate?.fill()
    }
  }
  private var delegate: AgencyDetailsViewModelDelegate?
  
  func setDelegate(_ delegate: AgencyDetailsViewModelDelegate) {
    self.delegate = delegate
    delegate.fill()
    verifyAgency()
  }
  
  func setAgency(_ agency: Agency) {
    self.agency = agency
  }
}

extension AgencyDetailsViewModel {
  public var name: String {
    return agency?.name ?? ""
  }
  
  public var openingHours: String {
    return agency?.openingHours?.joined(separator: "\n") ?? ""
  }
  
  public var phoneNumberLabel: String {
    return agency?.phoneNumber ?? ""
  }
}

extension AgencyDetailsViewModel {
  
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
  
  
  
  func fetchAgencyDetails() {
    guard let agency = agency else { return }
    googleClient.getGooglePlaceDetails(placeID: agency.placeID) { (response) in
      AgencyAdapter.updateIfNeed(agency: agency, details: response.result)
      AgencyAdapter.saveAgency(agency)
      self.delegate?.fill()
    }
  }
}
