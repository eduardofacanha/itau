//
//  Agencia.swift
//  ItauChallenge
//
//  Created by Eduardo Façanha on 30/11/19.
//  Copyright © 2019 Eduardo Façanha. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import CoreLocation

@objc(Agency)
class Agency: NSManagedObject {
  
  @NSManaged var placeID: String
  @NSManaged var name: String?
  @NSManaged var phoneNumber: String?
  @NSManaged var openingHours: Set<String>?
  @NSManaged internal var latitude: CLLocationDegrees
  @NSManaged internal var longitude: CLLocationDegrees
  
  var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}

class AgencyAdapter: NSObject {
  
  static func createAgencys(places: [Place], completion: @escaping ([Agency]) -> Void){
    var agencys = [Agency]()
    CoreDataManager.shared.foregroundOperation { (managedContext) in
      guard let managedContext = managedContext else { return }
      places.forEach { (place) in
        guard let agency = createAgency(place: place, managedContext: managedContext) else { return }
        agencys.append(agency)
      }
      completion(agencys)
    }
  }
    
    static func createAgency(place: Place,
                             managedContext: NSManagedObjectContext) -> Agency? {
      
      let entity = Agency.entity()
      let agency = NSManagedObject(entity: entity,
                                   insertInto: nil) as? Agency
      agency?.placeID = place.placeID
      agency?.latitude = place.geometry.location.latitude
      agency?.longitude = place.geometry.location.longitude
      agency?.name = place.name
      return agency
    }
    
    static func saveAgency(_ agency: Agency) {
      CoreDataManager.shared.foregroundOperation { (managedContext) in
        guard let managedContext = managedContext else { return }
        managedContext.insert(agency)
        let save = {
          if managedContext.hasChanges {
            do {
              try managedContext.save()
            } catch {
              managedContext.redo()
            }
          }
        }
        
        getAgency(placeID: agency.placeID, managedContext: managedContext) { (existentAgency) in
          if let existentAgency = existentAgency {
            if update(existentAgency: existentAgency, agency: agency) {
              save()
            }
          } else {
            save()
          }
        }
      }
    }
    
    static private func getAgency(placeID: String,
                                  managedContext: NSManagedObjectContext,
                                  completion: @escaping (Agency?) -> Void) {
      let predicate = NSPredicate.init(format: "placeID == %@", placeID)
      let fetchRequest = Agency.fetchRequest()
      fetchRequest.predicate = predicate
      var agency: Agency?
      do {
        agency = try managedContext.fetch(fetchRequest).first as? Agency
      } catch {
        agency = nil
      }
      completion(agency)
    }
    
    static func getAgency(placeId: String, completion: @escaping (Agency?) -> Void) {
      CoreDataManager.shared.foregroundOperation { (managedContext) in
        guard let managedContext = managedContext else { return }
        getAgency(placeID: placeId, managedContext: managedContext, completion: completion)
      }
    }
    
    static private func update(existentAgency: Agency, agency: Agency) -> Bool {
      var hasChange = false
      
      if existentAgency.placeID != agency.placeID {
        existentAgency.placeID = agency.placeID
        hasChange = true
      }
      
      if existentAgency.coordinate.latitude != agency.coordinate.latitude {
        existentAgency.latitude = agency.coordinate.latitude
        hasChange = true
      }
      if existentAgency.coordinate.longitude != agency.coordinate.longitude {
        existentAgency.longitude = agency.coordinate.longitude
        hasChange = true
      }
      
      if existentAgency.name != agency.name {
        existentAgency.name = agency.name
        hasChange = true
      }
      return hasChange
    }
    
    static func updateIfNeed(agency: Agency, details: GooglePlaceDetailsResponse.Details) {
      if let openingHours = details.openingHours?.weekday {
        agency.openingHours = Set<String>.init(openingHours)
      }
      if let phoneNumber = details.phoneNumber {
        agency.phoneNumber = phoneNumber
      }
    }
  }
