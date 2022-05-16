//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Fabio Tiberio on 15/05/21.
//

import Foundation

class FlickrAPI {
    //MARK: Properties
    let restBaseURL = "https://www.flickr.com/services/rest/"
    let apiKey = "1772f04faf15461b42b6bd3559540d68"
    let restClient: RestClient
    /// The page number to request to the Flickr API
    var pageNumber: Int = 1
    
    //MARK: Initializer
    init() {
        restClient = RestClient(stringURL: restBaseURL)
    }
    //MARK: Methods
    /// List of the Flickr API's methods
    enum Method: String {
        case getPhotosSearch = "flickr.photos.search"
    }
    
    //MARK: Arguments
    /// List of Arguments that you can add to the flickr.photos.search method
    enum Arguments: String, CaseIterable {
        case method
        case apiKey = "api_key"
        case latitude = "lat"
        case longitude = "lon"
        case perpage = "per_page"
        case page = "page"
        case format
        case noJsonCallback = "nojsoncallback"
    }
    //MARK: Argument Values
    /// Default values for Arguments that you can add to the flickr.photos.search
    enum ArgumentValues: String {
        case noJsonCallaback = "1"
        case photosPerPage = "30"
        case responseFormat = "json"
    }
    /// Creates the endpoint to use with the method [flickr.photos.search](https://www.flickr.com/services/api/flickr.photos.search.html).
    private func craftPhotosSearchEndpoint(latitude: Double, longitude: Double) {
        clearEndpointArguments()
        
        restClient.addQueryItem(name: Arguments.method.rawValue, value: Method.getPhotosSearch.rawValue)
        restClient.addQueryItem(name: Arguments.apiKey.rawValue, value: apiKey)
        restClient.addQueryItem(name: Arguments.latitude.rawValue, value: "\(latitude)")
        restClient.addQueryItem(name: Arguments.longitude.rawValue, value: "\(longitude)")
        restClient.addQueryItem(name: Arguments.perpage.rawValue, value: ArgumentValues.photosPerPage.rawValue)
        restClient.addQueryItem(name: Arguments.format.rawValue, value: ArgumentValues.responseFormat.rawValue)
        restClient.addQueryItem(name: Arguments.noJsonCallback.rawValue, value: ArgumentValues.noJsonCallaback.rawValue)
        restClient.addQueryItem(name: Arguments.page.rawValue, value: "\(pageNumber)")
        //Transform the dictionary into URLQueryItem array
        craftQueryItems()
    }
    /// Removes all the query items from the REST URL
    private func clearEndpointArguments() {
        restClient.removeAllQueryItems()
    }
    /// Creates an array of URLQueryItems from a [String:String] dictionary.
    private func craftQueryItems() {
        var queryItems = [URLQueryItem]()
        // Creates a query item for each argument
        for (key, value) in restClient.queryItems {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        // Adds the query items created to the base url
        restClient.components.queryItems = queryItems
    }
    //MARK: Get Photos Search Call
    ///Starts a data task using the  [flickr.photos.search API Method](https://www.flickr.com/services/api/flickr.photos.search.html).
    ///- parameter completion: A closure which runs after the download is finished.
    func getPhotosSearch(latitude: Double, longitude: Double, completion: @escaping ([PhotoInformation])->Void) {
        // Creates the REST Endpoint to use
        craftPhotosSearchEndpoint(latitude: latitude, longitude: longitude)
        // Perform data task
        restClient.performTask(url: restClient.components.url!, response: SearchPhotosResponse.self) { (searchPhotosResponse, error) in
            guard let response = searchPhotosResponse, response.photos.pages > 0 else {
                completion([])
                return
            }
            // Update the page number for the next fetch
            self.pageNumber = Int(arc4random()) % response.photos.pages
            completion(response.photos.photo)
        }
    }
    //MARK: Get Image Data
    /// Get the image data from the given URL
    func getImageData(from url: URL, completion: @escaping (Data?, Error?)->Void) {
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            completion(data, nil)
        }.resume()
    }
}

