//
//  Pin+Extension.swift
//  VirtualTourist
//
//  Created by Fabio Tiberio on 14/05/21.
//

import CoreData

extension Pin {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = Date()
    }
}
