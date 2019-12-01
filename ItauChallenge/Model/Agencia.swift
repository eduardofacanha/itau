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

class Agency: NSManagedObject {
  
  @NSManaged var placeID: String?
  @NSManaged var name: String?
  @NSManaged var phoneNumber: String?
//  @NSManaged var openingHours: Set<String>?
  @NSManaged internal var latitude: CLLocationDegrees
  @NSManaged internal var longitude: CLLocationDegrees
  
  var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}

class AgencyAdapter: NSObject {
  
  static func insertAgency(place: Place) {
    guard let managedContext = CoreDataManager.shared.managedContext else { return }
    
    let save = {
      if managedContext.hasChanges {
        do {
          try managedContext.save()
        } catch {
          managedContext.redo()
        }
      }
    }
    
    getAgency(placeId: place.placeID, managedContext: managedContext) { (existentAgency) in
      if let existentAgency = existentAgency {
        if update(existentAgency: existentAgency, place: place) {
          save()
        }
      } else {
        let entity = Agency.entity()
        
        let agency = NSManagedObject(entity: entity,
                                     insertInto: managedContext) as? Agency
        agency?.placeID = place.placeID
        agency?.latitude = place.geometry.location.latitude
        agency?.longitude = place.geometry.location.longitude
        agency?.name = place.name
        save()
      }
    }

   
  }
  
  static private func getAgency(placeId: String,
                        managedContext: NSManagedObjectContext,
                        completion: @escaping (Agency?) -> Void) {
    let fetchRequest = Agency.fetchRequest()
    var agencys: Agency?
    do {
      agencys = try managedContext.fetch(fetchRequest).first as? Agency
    } catch {
      agencys = nil
    }
    completion(agencys)
  }
  
  static func getAgency(placeId: String, completion: @escaping (Agency?) -> Void) {
    guard let managedContext = CoreDataManager.shared.managedContext else { return }
    getAgency(placeId: placeId, managedContext: managedContext, completion: completion)
  }
  
  static private func update(existentAgency: Agency, place: Place) -> Bool {
    var hasChange = false
    
    if existentAgency.placeID != place.placeID {
      existentAgency.placeID = place.placeID
      hasChange = true
    }
    
    if existentAgency.coordinate.latitude != place.geometry.location.latitude {
      existentAgency.latitude = place.geometry.location.latitude
      hasChange = true
    }
    if existentAgency.coordinate.longitude != place.geometry.location.longitude {
      existentAgency.longitude = place.geometry.location.longitude
      hasChange = true
    }
    
    if existentAgency.name != place.name {
      existentAgency.name = place.name
      hasChange = true
    }
    return hasChange
  }
}

class CoreDataManager: NSObject {
  static let shared = CoreDataManager()
  
  private var appDelegate: AppDelegate? {
    return UIApplication.shared.delegate as? AppDelegate
  }
  public var managedContext: NSManagedObjectContext? {
    return appDelegate?.persistentContainer.viewContext
  }
  
  private override init() { }
}
