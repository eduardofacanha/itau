//
//  GoogleClient.swift
//  ItauChallenge
//
//  Created by Eduardo Façanha on 30/11/19.
//  Copyright © 2019 Eduardo Façanha. All rights reserved.
//

import Foundation
import CoreLocation

protocol GoogleClientRequest {
  
  var googlePlacesKey : String { get set }
  func getGooglePlacesData(keyword: String,
                           location: CLLocation,
                           radius: Int,
                           completion: @escaping (GooglePlacesResponse?, Error?) -> Void)
  func getGooglePlaceDetails(placeID: String, completion: @escaping (GooglePlaceDetailsResponse?, Error?) -> Void)
  
}

class GoogleClient: GoogleClientRequest {
  
  private let session: URLSession = {
    let config: URLSessionConfiguration = .default
    config.timeoutIntervalForRequest = Constants.timeOut
    config.timeoutIntervalForResource = Constants.timeOut
    return URLSession.init(configuration: config)
  }()
  
  internal var googlePlacesKey: String = Constants.googlePlacesAPIKey
  
  public func getGooglePlacesData(keyword: String,
                           location: CLLocation,
                           radius: Int,
                           completion: @escaping (GooglePlacesResponse?, Error?) -> Void)  {
    
    let url = googlePlacesDataURL(apiKey: googlePlacesKey, location: location, keyword: keyword)
    let task = session.dataTask(with: url) { (data, _, error) in
      if let error = error {
        completion(nil, error)
      }
      guard let data = data,
        let response = try? JSONDecoder().decode(GooglePlacesResponse.self, from: data) else {
          completion(GooglePlacesResponse(results:[]), nil)
          return
      }
      completion(response, error)
    }
    task.resume()
  }
  
  public func getGooglePlaceDetails(placeID: String, completion: @escaping (GooglePlaceDetailsResponse?, Error?) -> Void) {
    
    let url = googlePlaceDetailsURL(apiKey: googlePlacesKey, placeID: placeID)

    let task = session.dataTask(with: url) { data, _, error in
      if let error = error {
        completion(nil, error)
      }
      guard let data = data,
        let response = try? JSONDecoder().decode(GooglePlaceDetailsResponse.self, from: data) else { return }
      completion(response, error)
    }
    
    task.resume()
  }
  
  private func googlePlacesDataURL(apiKey: String, location: CLLocation, keyword: String) -> URL {
    let locationString = String(location.coordinate.latitude) + "," + String(location.coordinate.longitude)
    var urlComponents = URLComponents()
       urlComponents.scheme = Constants.scheme
       urlComponents.host = Constants.root
       urlComponents.path = Constants.searchPath
       urlComponents.queryItems = [URLQueryItem.init(name: "location", value: locationString),
                                   URLQueryItem.init(name: "rankby", value: "distance"),
                                   URLQueryItem.init(name: "keyword", value: keyword),
                                   URLQueryItem.init(name: "key", value: apiKey)]
    
    return urlComponents.url!
  }
  
  // create the URL to request a JSON from Google
  private func googlePlaceDetailsURL(apiKey: String, placeID: String) -> URL {
    var urlComponents = URLComponents()
       urlComponents.scheme = Constants.scheme
       urlComponents.host = Constants.root
       urlComponents.path = Constants.detailsPath
       urlComponents.queryItems = [URLQueryItem.init(name: "key", value: apiKey),
                                   URLQueryItem.init(name: "place_id", value: placeID)]
    
    return urlComponents.url!
  }
  
}


