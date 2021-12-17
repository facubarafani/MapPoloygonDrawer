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
    var currentPolygon = Polygon()
    var mapPolygons = [GMSPolygon]() {
        didSet {
            mapPolygons.forEach { $0.map = self.mapView }
        }
    }
    
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
            
            self.fetchLocallyStoredPolygons()
        }.catch { error in
            self.view.makeToast("Error while attempting to init map.")
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
            savePolygonAndEmptyCurrentPolygon()
        }
        // Changes variable value to inverse
        isCreatingPolygon = !isCreatingPolygon
    }
    
    private func savePolygonAndEmptyCurrentPolygon() {
        if !currentPolygon.points.isEmpty {
            PolygonRepository.shared.store(polygon: currentPolygon)
                .done {
                    self.currentPolygon = Polygon()
                    self.fetchLocallyStoredPolygons()
                    self.clearMap()
                    self.view.makeToast("Polygon saved successfully.")
                }
                .catch { error in
                    self.view.makeToast("Error occurred when attempting to save polygon/")
                }
        }
    }
    
    private func clearMap() {
        mapView.clear()
        mapPolygons.forEach { $0.map = self.mapView }
    }
    
    private func fetchLocallyStoredPolygons() {
        PolygonRepository.shared.fetchAll()
            .done { polygons in
                let gMapsPolygons = polygons.map { $0.getGMSPolygon() }
                self.mapPolygons = gMapsPolygons
            }
            .catch { _ in
                self.view.makeToast("Error attempting to fetch locally stored polygons.")
            }
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
        clearMap()
        for p in currentPolygon.points {
            p.toMarker().map = mapView
        }
        let polygon = currentPolygon.getGMSPolygon()
        polygon.map = mapView
    }
}

