//
//  ViewController+Extensions.swift
//  VirtualTourist
//
//  Created by Fabio Tiberio on 15/05/21.
//

import UIKit
import MapKit

extension UIViewController {
    /// Indicates that the app is loading data
    ///- parameter activityIndicator: the activity indicator to show/hide
    ///- parameter controls: the controls to enable/disable by calling the `setUIState(controls:enabled:)` method. Empty by default.
    ///- parameter isLoading: if true the activity indicator starts animating. If false the activity indicator stops animating.
    func loading(activityIndicator: UIActivityIndicatorView ,controls: [UIControl] = [] ,isLoading: Bool) {
        DispatchQueue.main.async {
            isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
            if !controls.isEmpty {
                self.setUIState(controls: controls, enabled: !isLoading)
            }
        }
    }
    ///Disables/enables all the controls passed
    ///- parameter controls: All the controls to enable/disable
    ///- parameter enabled: Determines wheter the controls should be enabled or disabled
    func setUIState(controls: [UIControl], enabled: Bool) {
        for control in controls {
            control.isEnabled = enabled
        }
    }
    ///Creates an alert with the given parameters and presents it to the user
    func showAlert(title: String? = "Error" ,message: String? = "Something went wrong", _ actions: [UIAlertAction]? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let actions = actions {
            for action in actions {
                alertVC.addAction(action)
            }
        } else {
            alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        }
        DispatchQueue.main.async {
            self.present(alertVC, animated: true)
        }
    }
    //MARK: User Defaults
    /// Generic function that lets you get a value from a UserDefaults dictionary key
    func getUserDefaultsValue<T>(key: String) -> T {
        return UserDefaults.standard.value(forKey: key) as! T
    }
    /// Generic function that lets you to set a value for a UserDefaults dictionary key
    func setUserDefaultsValue<T>(value: T, key: String) {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    //MARK: Annotation
    /// Creates an annotation from a Pin Object and add it to the map
    func addAnnotation(from pin: Pin, to map: MKMapView) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        map.addAnnotation(annotation)
    }
}
