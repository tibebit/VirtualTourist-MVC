//
//  PhotoAlbumViewCell.swift
//  VirtualTourist
//
//  Created by Fabio Tiberio on 15/05/21.
//

import UIKit

class PhotoAlbumViewCell: UICollectionViewCell, Cell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    static var defaultIdentifier = "PhotoAlbumCell"
}
