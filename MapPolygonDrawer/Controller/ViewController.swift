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
import PromiseKit

class ViewController: UIViewController {
    @IBOutlet weak var addFloatingButton: MDCFloatingButton!
    @IBOutlet weak var mapView: GMSMapView!
    
    var userLocationCoordinate: CLLocationCoordinate2D?
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapView()
        setText()
        setUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initMap()
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
        mapView.isHidden = false
    }
    
    private func initMap() {
        firstly {
            CLLocationManager.requestLocation(authorizationType: .whenInUse).lastValue
        }.done { location in
            self.userLocationCoordinate = location.coordinate
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude,
                                                  zoom: 16)
            self.mapView.animate(to: camera)
            self.mapView.delegate = self
        }.catch { error in
            debugPrint("UbicacionVC-initMap-requestLocation-error \(error)")
        }
    }
    
    private func deinitMap() {
        mapView.clear()
        mapView.delegate = nil
    }
    
    
}

extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker()
        marker.position = coordinate
        marker.map = mapView
    }
}

