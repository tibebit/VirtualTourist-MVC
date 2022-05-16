//
//  PhotoAlbumVC.swift
//  VirtualTourist
//
//  Created by Fabio Tiberio on 14/05/21.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumVC: UIViewController {
    struct Constants {
        static let segueIdentifier = "PhotoAlbum"
        fileprivate static let defaultSpace:CGFloat = 3.0
    }
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    //MARK: Properties
    var dataController: DataController!
    lazy var backgroundContext: NSManagedObjectContext = {
        return dataController.backgroundContext!
    }()
    var pin: Pin!
    private lazy var flickrAPI: FlickrAPI? = {
        return FlickrAPI()
    }()
    
    /// Holds the Photo Image URLs
    private var images:[UIImage?] = [UIImage]()
    private var photoAlbum: [Photo] = [Photo]()
     //MARK: Lifecycle
    private func setupDelegates() {
        mapView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSpacing(Constants.defaultSpace, lineSpacingConstant: 3, interitemSpacingConstant: 0)
        setupDelegates()
        centerMapOnPinCoordinates(latitude: pin.latitude, longitude: pin.longitude)
        addAnnotation(from: pin, to: mapView)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        performFetch()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        flickrAPI = nil
    }
    //MARK: Fetch Request
    /// Create a FetchRequest for a Photo Managed Object
    private func setupFetchRequest()-> NSFetchRequest<Photo> {
        let photoFetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        let predicate = NSPredicate(format: "pin == %@", pin)
        photoFetchRequest.sortDescriptors = [sortDescriptor]
        photoFetchRequest.predicate = predicate
        return photoFetchRequest
    }
    /// Perform a fetch from the background context
    private func performFetch() {
        let fetchRequest = setupFetchRequest()
        do {
            photoAlbum = try backgroundContext.fetch(fetchRequest)
            photoAlbum.forEach { (photo) in
                images.append(UIImage(data: photo.imgData!))
            }
            collectionView.reloadData()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        // If a pin has not photos associated downloads them from the Flickr API
        if photoAlbum.isEmpty {
            downloadPhotosFromFlickr()
        }
    }
    //MARK: Editing
    /// Save a Photo Object to the persistent store
    private func savePhoto(from data: Data, context: NSManagedObjectContext) {
        let photo = Photo(context: context)
        photo.imgData = data
        let pin = context.object(with: self.pin.objectID) as! Pin
        pin.addToPhotos(photo)
        photoAlbum.append(photo)
        try? context.save()
    }
    //MARK: MapView Setup
    ///Set the initial the region of the mapView. The center of the map is based on the latitude and logngitude given.
    private func centerMapOnPinCoordinates(latitude: CLLocationDegrees, longitude: CLLocationDegrees, latitudeDelta: CLLocationDegrees  = 7.0, longitudeDelta:CLLocationDegrees = 7.0) {
        mapView.setRegion(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: latitude,
                    longitude: longitude),
                span: MKCoordinateSpan(
                    latitudeDelta: getUserDefaultsValue(key: "latitudeDelta") ?? latitudeDelta,
                    longitudeDelta:getUserDefaultsValue(key: "longitudeDelta") ?? longitudeDelta)),
                animated: true
            )
    }
    //MARK: Flickr API
    /// Starts loading photos associated with the pin from the Flickr API. Once the download is finished, the closure `handlePhotoSearchResponse` is called
    private func downloadPhotosFromFlickr() {
        userInteraction(for: collectionView, isEnabled: false)
        self.flickrAPI?.getPhotosSearch(latitude: pin.latitude, longitude: pin.longitude, completion: self.handlePhotosSearchResponse(photos:))
    }
    /// Retrieves the URLs of the photos downloaded from Flickr. Shows an alert if the array of photos is empty
    ///- parameter photos: contains all the photos retrieved from the Flickr API
    func handlePhotosSearchResponse(photos: [PhotoInformation]) {
        if photos.isEmpty {
            showAlert(message: "Unable to download the photos for the location selected")
            return
        }
        downloadImagesData(photos: photos)
        
        DispatchQueue.main.async {
            self.userInteraction(for: self.collectionView, isEnabled: true)
        }
    }
    /// Fills the data source with the downloaded images and updates the collection view
    func downloadImagesData(photos: [PhotoInformation]) {
        photos.forEach { (photo) in
            //Make the literal appear in the photo
            images.append(#imageLiteral(resourceName: "icons8-full-image-80"))
            self.updateCollectionView()
            
            flickrAPI?.getImageData(from: photo.imageURL!, completion: { (data, error) in
                guard let data = data else {return}
                // saves the photo to the persistent store
                self.savePhoto(from: data, context: self.backgroundContext)
                // Removes the placeholder image from the array
                self.images.removeFirst()
                // Append the downloaded image to the array
                self.images.append(UIImage(data: data))

                self.updateCollectionView()
            })
        }
    }
    /// Removes all the photos from the persistent store. Downloads a new set of photos from Flickr.
    func reloadPhotosFromFlickr() {
        images = [UIImage]()
        for photo in photoAlbum {
            backgroundContext.delete(photo)
        }
        try? backgroundContext.save()
        photoAlbum = [Photo]()
        downloadPhotosFromFlickr()
    }
    //MARK: UI Functions
    /// Forces the collectionView to reload its data
    func updateCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    //MARK: Actions
    /// Calls `reloadPhotosFromFlickr`
    @IBAction func newCollectionButtonPressed() {
        reloadPhotosFromFlickr()
    }
}
//MARK: MKMapViewDelegate
extension PhotoAlbumVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}
//MARK: CollectionView
extension PhotoAlbumVC: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    ///Enable/disable the user interaction with the collection view
    func userInteraction(for collectionView: UICollectionView, isEnabled: Bool) {
        collectionView.isUserInteractionEnabled = isEnabled
    }
    //MARK: Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoAlbumViewCell.defaultIdentifier, for: indexPath) as! PhotoAlbumViewCell
        cell.imageView.image = images[indexPath.row]
        return cell
    }
    //MARK: UICV Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        images.remove(at: indexPath.row)
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [indexPath])
        }
        backgroundContext.delete(photoAlbum[indexPath.row])
        try? backgroundContext.save()
        photoAlbum.remove(at: indexPath.row)
    }
    //MARK: UICV Flow Layout
    /// Set the spacing between each line/item in the collectionView
    func setSpacing(_ space: CGFloat, lineSpacingConstant: CGFloat, interitemSpacingConstant: CGFloat) {
        flowLayout.minimumLineSpacing = space + lineSpacingConstant
        flowLayout.minimumInteritemSpacing = space + interitemSpacingConstant
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = view.frame.size.width
        let width = (totalWidth - (Constants.defaultSpace * 2)) / 3
        return CGSize(width: width, height: width)
    }
}
