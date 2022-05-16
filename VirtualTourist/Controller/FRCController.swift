//
//  FRCController.swift
//  VirtualTourist
//
//  Created by Fabio Tiberio on 20/05/21.
//


import UIKit
import CoreData

class FRCController<ObjectType: NSManagedObject, CellType: UICollectionViewCell>: NSObject, UICollectionViewDataSource, NSFetchedResultsControllerDelegate where CellType:Cell {
    var frc: NSFetchedResultsController<ObjectType>!
    var configureFromCoreData: (CellType, ObjectType)->Void
    var configureFromAPICall:(CellType, URL)->Void
    var performAPICall: ()->Void
    var resources: [URL]
    var indexesToUpdate:[IndexPath] = []
    var batchUpdateChangeType: NSFetchedResultsChangeType!
    var collectionView: UICollectionView
    
    init(collectionView: UICollectionView, managedObjectContext: NSManagedObjectContext, fetchRequest: NSFetchRequest<ObjectType>, resources: [Any],configureFromCoreData: @escaping (CellType, ObjectType) -> Void, configureFromAPICall: @escaping (CellType, URL)->Void, performAPICall: @escaping ()->Void) {
        self.collectionView = collectionView
        self.resources = []
        if let resources = resources as? [URL] {
            self.resources = resources
        }
        self.configureFromCoreData = configureFromCoreData
        self.configureFromAPICall = configureFromAPICall
        self.performAPICall = performAPICall
        super.init()
        setupFRC(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext)
    }
    /// Setup a Fetched Results Controller and perform a fetch from the background context
    private func setupFRC(fetchRequest: NSFetchRequest<ObjectType>, managedObjectContext: NSManagedObjectContext) {
        frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        performFetch()
    }
    /// Perform a fetch from the background context
    private func performFetch() {
        do {
            try frc.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        // If a pin has photos associated, fetch them from CoreData. Otherwise download the photos from the Flickr API
        if !hasSavedObjects() {
            performAPICall()
        }
    }
    func saveObjects(imageURLs: [URL]) {
        let context = frc.managedObjectContext
        context.perform {
            imageURLs.forEach { (url) in
                let data = try? Data(contentsOf: url)
                guard let imgData = data else {return}
                let photo = ObjectType(context: context)
                photo.imgData = imgData
                let object = context.object(with: self.object.objectID) as! ObjectType
                pin.addToPhotos(photo)
                try? context.save()
            }
        }
    }
    //MARK: Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if hasSavedObjects() {
            return frc.sections?[0].numberOfObjects ?? resources.count
        }
        return resources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellType.defaultIdentifier, for: indexPath) as! CellType
        
        if hasSavedObjects() {
            //Here we configure a cell with the data fetched from CoreData
            let object = frc.object(at: indexPath)
            configureFromCoreData(cell, object)
        } else {
            //Here we configure a cell with the data downloaded from the Internet
            configureFromAPICall(cell, resources[indexPath.row])
            if self.resources[indexPath.row] == self.resources.last {
                collectionView.isEditing = true
            }
        }
        return cell
    }
    //MARK: Utility Functions
    func hasSavedObjects()->Bool {
        (frc.fetchedObjects?.count ?? 0 > 0) ? true: false
    }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        indexesToUpdate = []
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        performBatchUpdates(for: batchUpdateChangeType, indexPath: indexesToUpdate)
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            indexesToUpdate.append(newIndexPath!)
            batchUpdateChangeType = .insert
            break
        case .delete:
            indexesToUpdate.append(indexPath!)
            batchUpdateChangeType = .delete
            break
        default:
            fatalError("unknown operation detected")
        }
    }
    /// Performs updates to the collectionView at the given index paths
    ///- parameter changeType: the type of change that the collectionView should perform. Either insert or delete
    ///- parameter indexPath: the list of index paths that will be affected by the changes
    func performBatchUpdates(for changeType: NSFetchedResultsChangeType, indexPath: [IndexPath]) {
        switch changeType {
        case .insert:
            DispatchQueue.main.async {
                self.collectionView.performBatchUpdates {
                    self.collectionView.insertItems(at: indexPath)
                }
            }
        case .delete:
            DispatchQueue.main.async {
                self.collectionView.performBatchUpdates {
                    self.collectionView.deleteItems(at: indexPath)
                }
            }
        default:
            ()
        }
    }
}

