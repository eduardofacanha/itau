//
//  ResponseModels.swift
//  ItauChallenge
//
//  Created by Eduardo Façanha on 30/11/19.
//  Copyright © 2019 Eduardo Façanha. All rights reserved.
//

import Foundation

struct GooglePlacesResponse : Codable {
  let results: [Place]
  enum CodingKeys: CodingKey {
    case results
  }
}
struct GooglePlaceDetailsResponse : Codable {
  let result: PhoneNumber
  enum CodingKeys: CodingKey {
    case result
  }
}

struct PhoneNumber: Codable {
  let phoneNumber: String
  enum CodingKeys: String, CodingKey {
    case phoneNumber = "formatted_phone_number"
  }
}

struct Place: Codable {
  let geometry: Location
  let placeID: String
  let name: String
  let openingHours: OpenNow?
  let address: String
  enum CodingKeys: String, CodingKey {
    case geometry = "geometry"
    case placeID = "place_id"
    case name = "name"
    case openingHours = "opening_hours"
    case address = "vicinity"
  }
  struct Location: Codable {
    let location: LatLong
    enum CodingKeys: String, CodingKey {
      case location = "location"
    }
    
    struct LatLong: Codable {
      
      let latitude: Double
      let longitude: Double
      enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
      }
    }
  }
  struct OpenNow: Codable {
    let open : Bool
    enum CodingKeys : String, CodingKey {
      case open = "open_now"
    }
  }
}
