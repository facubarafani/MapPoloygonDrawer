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
    var isCreatingPolygon: Bool = false
    var currentPoints = [Point]()
    var currentPolygon = Polygon()
    
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
        addFloatingButton.setImage(R.image.images.add(), for: .normal)
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
    
    @IBAction func addFloatingButtonPressed(_ sender: Any) {
        // if last state before pressing button is user not creating polygon -> now it turns into true
        if !isCreatingPolygon {
            // sets cross icon when isCreatingPolygon is turning into true
            addFloatingButton.setImage(R.image.images.close(), for: .normal)
        } else {
            // sets add icon when isCreatingPolygon is turning into false
            addFloatingButton.setImage(R.image.images.add(), for: .normal)
        }
        // Changes variable value to inverse
        isCreatingPolygon = !isCreatingPolygon
    }
    
}

extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // if user is not creating polygon -> then ignore taps at screen
        if !isCreatingPolygon {
            return
        }
        // On each coordinate where user tapped generates a marker
        let point = Point(coordinate: coordinate)
        let marker = point.toMarker()
        marker.map = mapView
        currentPolygon.points.append(point)
        mapView.clear()
        for p in currentPolygon.points {
            p.toMarker().map = mapView
        }
        let polygon = currentPolygon.getGMSPolygon()
        polygon.map = mapView
    }
}

