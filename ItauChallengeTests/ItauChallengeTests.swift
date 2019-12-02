//
//  ItauChallengTests.swift
//  ItauChallengeTests
//
//  Created by Eduardo Façanha on 01/12/19.
//  Copyright © 2019 Eduardo Façanha. All rights reserved.
//

import XCTest
import CoreLocation
@testable import ItauChallenge

class ItauChallengTests: XCTestCase {

    let locationManager = CLLocationManager()
    let googleClient = GoogleClient()

    func testLocationAuthorization() {
      let status = CLLocationManager.authorizationStatus()
      let authorized = status == .authorizedWhenInUse || status == .authorizedAlways
      XCTAssert(authorized)
    }
    
    func testUserLocation() {
      XCTAssertNotNil(locationManager.location, "Witouth User Location")
    }
  
  func testAgencysSaveds() {
    guard let location = locationManager.location else { return XCTFail("Witouth User Location")}
    let creationPromise = self.expectation(description: "Creation of Agencys")
    let getPromise = self.expectation(description: "Restore the created Agencys")
    googleClient.getGooglePlacesData(keyword: Constants.itau, location: location, radius: Constants.searchRadius) { (response) in
      let resultsCount = response.results.count
      var creationCount = 0
      
      AgencyAdapter.createAgencys(places: response.results) { (agencys) in
        
        let get = {
          var agencysSaveds = [Agency]()
          var getCount = 0
          agencys.forEach { (agency) in
            AgencyAdapter.getAgency(placeId: agency.placeID) { (agency) in
              guard let agency = agency else { return XCTFail("Agency not saved")}
              agencysSaveds.append(agency)
              getCount += 1
              if getCount == resultsCount {
                getPromise.fulfill()
              }
            }
          }
        }
        
        agencys.forEach { (agency) in
          AgencyAdapter.saveAgency(agency) {
           creationCount += 1
            if creationCount == resultsCount {
              creationPromise.fulfill()
              get()
            }
          }
        }
      }
    }
    wait(for: [creationPromise, getPromise], timeout: 30)
  }
  
  var viewModelPromisse: XCTestExpectation?
  var injectionPromisse: XCTestExpectation?
  let viewModel = AgencyViewModel()
  var results: [Place]?
  func testAgencysPresenteds() {
    guard let location = locationManager.location else { return XCTFail("Witouth User Location")}
    injectionPromisse = self.expectation(description: "Load Agencys from WebService")
    viewModelPromisse = self.expectation(description: "Load Agencys from viewModel")
    viewModel.setDelegate(self)
    googleClient.getGooglePlacesData(keyword: Constants.itau, location: location, radius: Constants.searchRadius) { (response) in
      self.results = response.results
      self.injectionPromisse?.fulfill()
    }
    wait(for: [viewModelPromisse!, injectionPromisse!], timeout: 30)
    XCTAssertEqual(results?.count, viewModel.numberOfRows, "Diferent Numbers of agencys")
  }

}

extension ItauChallengTests: AgencyViewModelDelegate {
  func reload() {
    viewModelPromisse?.fulfill()
  }
}
