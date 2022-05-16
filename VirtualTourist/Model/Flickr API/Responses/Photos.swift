//
//  Photos.swift
//  BasicVirtuaTouristStructure
//
//  Created by Fabio Tiberio on 09/05/21.
//

import Foundation

struct Photos: Codable {
    var page: Int?
    var pages: Int
    var photosPerPage: Int?
    var total: Int
    var photo: [PhotoInformation]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case photosPerPage = "perpage"
        case total
        case photo
    }
}
