//
//  Point.swift
//  MapPolygonDrawer
//
//  Created by Facundo Barafani on 16/12/2021.
//

import Foundation
import RealmSwift
import MapKit
import GoogleMaps

@objcMembers class Point: Object {
    dynamic var longitude: Double = 0
    dynamic var latitude: Double = 0
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init()
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    func toMarker() -> GMSMarker {
        let marker = GMSMarker()
        marker.position = coordinate
        let markerView = UIImageView(image: R.image.images.dot())
        markerView.tintColor = R.color.colors.primaryDark()
        marker.iconView = markerView
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5);
        return marker
    }
}
