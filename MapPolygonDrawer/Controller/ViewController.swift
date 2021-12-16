//
//  ViewController.swift
//  MapPolygonDrawer
//
//  Created by Facundo Barafani on 15/12/2021.
//

import UIKit
import GoogleMaps
import MaterialComponents
import SwiftyUserDefaults

class ViewController: UIViewController {
    @IBOutlet weak var addFloatingButton: MDCFloatingButton!
    @IBOutlet weak var mapView: GMSMapView!
    
    var userLocationCoordinate: CLLocationCoordinate2D?
    override func viewDidLoad() {
        super.viewDidLoad()
        setText()
        setUI()
    }
    
    @objc func setText() {}
    
    @objc func setUI() {
        addFloatingButton.setImage(R.image.images.add_black_24dp(), for: .normal)
        addFloatingButton.setImageTintColor(.white, for: .normal)
        addFloatingButton.setBackgroundColor(R.color.colors.primary(), for: .normal)
    }
    
    private func setMapView() {
        mapView.settings.myLocationButton = false
        mapView.isHidden = true
//         mapView.camera = GMSCameraPosition.userLastLocationCamera
        mapView.isHidden = false
    }


}

