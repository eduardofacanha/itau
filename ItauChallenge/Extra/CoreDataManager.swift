//
//  CoreDataManager.swift
//  ItauChallenge
//
//  Created by Eduardo Façanha on 01/12/19.
//  Copyright © 2019 Eduardo Façanha. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
  static let shared = CoreDataManager()
  
  private override init() { }
  
  func foregroundOperation(completion: @escaping (NSManagedObjectContext?) -> Void) {
    DispatchQueue.main.async {
      let delegate = UIApplication.shared.delegate as? AppDelegate
      let managedContext = delegate?.persistentContainer.viewContext
      completion(managedContext)
    }
  }
}
