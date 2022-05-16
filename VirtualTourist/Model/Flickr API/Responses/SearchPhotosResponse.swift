//
//  SearchPhotosResponse.swift
//  BasicVirtuaTouristStructure
//
//  Created by Fabio Tiberio on 09/05/21.
//

import Foundation

struct SearchPhotosResponse: Codable {
    var photos: Photos
    var stat: String
}
