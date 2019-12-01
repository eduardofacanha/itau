//
//  ViewController.swift
//  ItauChallenge
//
//  Created by Eduardo Façanha on 30/11/19.
//  Copyright © 2019 Eduardo Façanha. All rights reserved.
//

import UIKit
import GooglePlaces

class ViewController: UITableViewController {
  
  lazy var googleClient: GoogleClientRequest = GoogleClient()
  private let locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    let status = CLLocationManager.authorizationStatus()
    if status == .authorizedWhenInUse  || status == .authorizedAlways {
      fetchGoogleData()
    } else {
      locationManager.requestWhenInUseAuthorization()
    }
  }
}

extension ViewController {
  func fetchGoogleData() {
    guard let location = locationManager.location else { return }
    googleClient.getGooglePlacesData(keyword: Constants.itau,
                                     location: location,
                                     radius: Constants.searchRadius) { (response) in
      response.results.forEach { (place) in
        self.googleClient.getGooglePlaceDetails(placeID: place.placeID) { (response) in
          print(response)
        }
      }
    }
  }
}

extension ViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedWhenInUse || status == .authorizedAlways {
      fetchGoogleData()
    }
  }
}
