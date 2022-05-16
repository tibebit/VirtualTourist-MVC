//
//  Photo.swift
//  BasicVirtuaTouristStructure
//
//  Created by Fabio Tiberio on 09/05/21.
//

import Foundation
///Holds all the information needed to build get the URL for images
struct PhotoInformation: Codable {
    var id: String
    var secret: String
    var serverId: String

    enum CodingKeys: String, CodingKey {
        case id
        case secret
        case serverId = "server"
    }
}
extension PhotoInformation {
    var imageURL: URL? {
        return URL(string: "https://live.staticflickr.com/\(serverId)/\(id)_\(secret)_q.jpg")!
    }
}
