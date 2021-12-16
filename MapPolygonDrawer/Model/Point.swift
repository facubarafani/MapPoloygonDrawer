//
//  Point.swift
//  MapPolygonDrawer
//
//  Created by Facundo Barafani on 16/12/2021.
//

import Foundation
import RealmSwift
import MapKit

@objcMembers class Point: Object {
    dynamic var longitude: Double = 0
    dynamic var latitude: Double = 0
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
