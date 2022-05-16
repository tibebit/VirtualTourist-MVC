//
//  RestClient.swift
//  VirtualTourist
//
//  Created by Fabio Tiberio on 15/05/21.
//

import Foundation

/// Rest Service Manager
class RestClient {
    //MARK: Properties
    ///The endpoint to use for our API calls
    var components: URLComponents
    /// A dictionary that holds all the arguments to add to a base rest URL
    var queryItems: [String: String]
    
    //MARK: Initializer
    init(stringURL: String) {
        queryItems = [:]
        components = URLComponents()
        if let components = URLComponents(string: stringURL) {
            self.components = components
        }
    }
    //MARK: Query Items Configuration
    func addQueryItem(name: String, value: String) {
        queryItems[name] = value
    }
    func updateQueryItem(name: String, newValue: String) {
        queryItems.updateValue(newValue, forKey: name)
    }
    func removeQueryItem(name: String) {
        queryItems.removeValue(forKey: name)
    }
    func removeAllQueryItems() {
        queryItems = [:]
    }
    //MARK: Requests
    func performTask<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?)->Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completionHandler(nil, error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                completionHandler(responseObject, nil)
            } catch {
                do {
                    let errorResponse = try decoder.decode(FlickrAPIResponse.self, from: data)
                    DispatchQueue.main.async {
                        completionHandler(nil, errorResponse)
                    }
                } catch {
                    completionHandler(nil, error)
                }
            }
        }
        task.resume()
    }
}
