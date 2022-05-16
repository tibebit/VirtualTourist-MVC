//
//  TravelLocationVC.swift
//  VirtualTourist
//
//  Created by Fabio Tiberio on 14/05/21.
//

import UIKit
import MapKit
import CoreData

class TravelLocationVC: UIViewController, UIGestureRecognizerDelegate {
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!

    //MARK: Properties
    var dataController: DataController!
    var frc: NSFetchedResultsController<Pin>!
    var longPressGestureRecognizer: UILongPressGestureRecognizer!
   
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Retrieves the information about the region coordinates saved during the last app usage
        getUserDefaultsValues()
        // Creates the Fetched Results Controller
        setupFRC()
        // Creates a gesture recognizer to detect the tap and hold gesture
        setupLongPressGestureRecognizer(for: mapView)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFRC()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        frc = nil
        
    }
    //MARK: Fetched Results Controller Handling
    fileprivate func setupFRC() {
        let pinFetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        pinFetchRequest.sortDescriptors = [sortDescriptor]
        
        frc = NSFetchedResultsController(fetchRequest: pinFetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        frc.delegate = self
        performFetch()
    }
    fileprivate func performFetch() {
        
        do {
            try frc.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        // If there are objects in the persistent store, add annotations on the map
        if let objects = frc.fetchedObjects , objects.count > 0 {
            mapView.removeAnnotations(mapView.annotations)
            addLoadedAnnotations(from: objects)
        }
    }
    //MARK: Annotations
    /// Add the annotations loaded from the persistent store to the map. Called once the app is started. Triggers `addAnnotation(from pin:)`
    private func addLoadedAnnotations(from pins: [Pin]?) {
        if let pins = pins {
            for pin in pins {
                addAnnotation(from: pin, to: mapView)
            }
        }
    }
    //MARK: User Defaults Handling
    ///Set the initial the region of the mapView. Takes the values from the UserDefaults dictionary
    private func getUserDefaultsValues() {
        
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: getUserDefaultsValue(key: "latitude"), longitude: getUserDefaultsValue(key: "longitude")), span: MKCoordinateSpan(latitudeDelta: getUserDefaultsValue(key: "latitudeDelta"), longitudeDelta: getUserDefaultsValue(key: "longitudeDelta"))), animated: true)
    }
    
    /// Save the current region coordinates to the UserDefaults dictionary
    private func setUserDefaultsValues() {
        setUserDefaultsValue(value: mapView.region.center.latitude, key: "latitude")
        setUserDefaultsValue(value: mapView.region.center.longitude, key: "longitude")
        setUserDefaultsValue(value: mapView.region.span.latitudeDelta, key: "latitudeDelta")
        setUserDefaultsValue(value: mapView.region.span.longitudeDelta, key: "longitudeDelta")
    }
    
    //MARK: Touch and Hold Gesture
    /// instantiate a gesture recognizer and add it to the view
    private func setupLongPressGestureRecognizer(for view: UIView) {
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        view.addGestureRecognizer(longPressGestureRecognizer)
    }
    /// Handles long press gesture. Calls `savePin()`
    @objc func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        // Drops an annotation when the user taps and holds the map
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            // Get the location of the tap
            let touchLocation = gestureRecognizer.location(in: mapView)
            // Translate the tap location into map coordinates
            let coordinates = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            mapView.setCenter(mapView.centerCoordinate,  animated: false)
            savePin(with: coordinates)
        }
    }
    //MARK: Pins
    ///Saves a pin object to core data. Triggers `NSFetchedResultsControllerDelegate` methods.
    func savePin(with coordinates: CLLocationCoordinate2D) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinates.latitude
        pin.longitude = coordinates.longitude
        
        try? dataController.viewContext.save()
    }
    func getCurrentPin(from annotation: MKAnnotation?) {
        guard let annotation = annotation else {
            return
        }
        let coordinate = annotation.coordinate
        let pin = frc.fetchedObjects?.first(where: { (pin) -> Bool in
            pin.latitude == coordinate.latitude && pin.longitude == coordinate.longitude
        })
        performSegue(withIdentifier: PhotoAlbumVC.Constants.segueIdentifier, sender: pin)
    }
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let pin = sender as? Pin else {
            return
        }
        if let photoAlbumVC = segue.destination as? PhotoAlbumVC {
                photoAlbumVC.dataController = dataController
            photoAlbumVC.pin = pin
            }
        }
}
//MARK: MKMapViewDelegate
extension TravelLocationVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //Save the region coordinates
        setUserDefaultsValues()
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        getCurrentPin(from: view.annotation)
        mapView.deselectAnnotation(view.annotation, animated: true)
    }
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
//MARK: FRC Delegate
extension TravelLocationVC: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            let pin = frc.object(at: newIndexPath!)
            addAnnotation(from: pin, to: mapView)
        default:
            ()
        }
    }
}
extension TravelLocationVC {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
