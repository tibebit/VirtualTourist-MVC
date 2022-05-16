//
//  FlickrAPIResponse.swift
//  BasicVirtuaTouristStructure
//
//  Created by Fabio Tiberio on 09/05/21.
//

import Foundation

struct FlickrAPIResponse: Codable {
    var stat: String
    var code: String?
    var message: String?
}

extension FlickrAPIResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
