//
//  ViewController.swift
//  ItauChallenge
//
//  Created by Eduardo Façanha on 30/11/19.
//  Copyright © 2019 Eduardo Façanha. All rights reserved.
//

import UIKit
import GooglePlaces

class AgencysTableViewController: UITableViewController {
  
  lazy var googleClient: GoogleClientRequest = GoogleClient()
  private let locationManager = CLLocationManager()
  private var dataSource = [Agency]()
  private let identifier = "AgencyCell"
  
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
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    let index = indexPath.row
    if dataSource.indices.contains(index) {
      let place = dataSource[index]
      cell.textLabel?.text = place.name
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let agencyViewController = segue.destination as? AgencyViewController,
      let indexPath = self.tableView.indexPathForSelectedRow,
      dataSource.indices.contains(indexPath.row) else { return }
    agencyViewController.agency = dataSource[indexPath.row]
    super.prepare(for: segue, sender: sender)
  }
}

extension AgencysTableViewController {
  func fetchGoogleData() {
    guard let location = locationManager.location else { return }
    googleClient.getGooglePlacesData(keyword: Constants.itau,
                                     location: location,
                                     radius: Constants.searchRadius) { (response) in
                                      AgencyAdapter.createAgencys(places: response.results) { agencys in
                                        self.insert(agencys: agencys)
                                      }
    }
  }
  
  func insert(agencys: [Agency]) {
    var indexPaths = [IndexPath]()
    agencys.forEach { (place) in
      indexPaths.append(IndexPath.init(row: dataSource.count, section: 0))
      self.dataSource.append(place)
    }
    DispatchQueue.main.async {
      self.tableView.insertRows(at: indexPaths, with: .automatic)
    }
  }
}

extension AgencysTableViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedWhenInUse || status == .authorizedAlways {
      fetchGoogleData()
    }
  }
}
