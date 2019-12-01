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
  func insert(agencys: [Agency], completion: @escaping (Agency) -> Void)
}

class AgencyViewModel: NSObject {
  
  public let identifier = "AgencyCell"
  
  lazy var googleClient: GoogleClientRequest = GoogleClient()
  private let locationManager = CLLocationManager()
  private var dataSource = [Agency]()
  
  private var delegate: AgencyViewModelDelegate
  
  init(delegate: AgencyViewModelDelegate) {
    self.delegate = delegate
    super.init()
    locationManager.delegate = self
    let status = CLLocationManager.authorizationStatus()
    if status != .authorizedWhenInUse && status != .authorizedAlways {
      locationManager.requestWhenInUseAuthorization()
    }
  }
  
  func fetchGoogleData() {
    guard let location = locationManager.location else { return }
    googleClient.getGooglePlacesData(keyword: Constants.itau,
                                     location: location,
                                     radius: Constants.searchRadius) { (response) in
                                      AgencyAdapter.createAgencys(places: response.results) { agencys in
                                        self.delegate.insert(agencys: agencys) {agency in
                                          self.dataSource.append(agency)
                                        }
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
    return IndexPath.init(row: numberOfRows, section: 0)
  }
}

extension AgencyViewModel: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedWhenInUse || status == .authorizedAlways {
      fetchGoogleData()
    }
  }
}
