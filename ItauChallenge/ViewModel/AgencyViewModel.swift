//
//  ViewModel.swift
//  ItauChallenge
//
//  Created by Eduardo Façanha on 01/12/19.
//  Copyright © 2019 Eduardo Façanha. All rights reserved.
//

import Foundation
import GooglePlaces

protocol AgencyViewModelDelegate {
  func reload()
}

class AgencyViewModel: NSObject {
  
  public let identifier = "AgencyCell"
  
  lazy var googleClient: GoogleClientRequest = GoogleClient()
  private let locationManager = CLLocationManager()
  private var dataSource = [Agency]()
  
  private var delegate: AgencyViewModelDelegate?
  
  override init() {
    super.init()
    locationManager.delegate = self
    let status = CLLocationManager.authorizationStatus()
    if status != .authorizedWhenInUse && status != .authorizedAlways {
      locationManager.requestWhenInUseAuthorization()
    }
  }
  
  func setDelegate(_ delegate: AgencyViewModelDelegate) {
    self.delegate = delegate
  }
  
  func fetchGoogleData() {
    guard let location = locationManager.location else { return }
    googleClient.getGooglePlacesData(keyword: Constants.itau,
                                     location: location,
                                     radius: Constants.searchRadius) { (response) in
                                      AgencyAdapter.createAgencys(places: response.results) { agencys in
                                        self.dataSource.append(contentsOf: agencys)
                                        self.delegate?.reload()
                                      }
    }
  }
  
  
}

extension AgencyViewModel {
  public var numberOfRows: Int {
    return dataSource.count
  }
  
  public func agency(indexPath: IndexPath) -> Agency {
    let index = indexPath.row
    return dataSource[index]
  }
  
  public var nextIndexPath: IndexPath {
    return IndexPath.init(row: numberOfRows - 1, section: 0)
  }
}

extension AgencyViewModel: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedWhenInUse || status == .authorizedAlways {
      fetchGoogleData()
    }
  }
}
