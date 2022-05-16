//
//  Photo+Extension.swift
//  VirtualTourist
//
//  Created by Fabio Tiberio on 14/05/21.
//

import CoreData

extension Photo {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = Date()
    }
}
