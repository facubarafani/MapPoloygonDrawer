//
//  PolygonRepositoru.swift
//  MapPolygonDrawer
//
//  Created by Facundo Barafani on 16/12/2021.
//

import Foundation
import RealmSwift
import PromiseKit

class PolygonRepository {
    static let shared = PolygonRepository()
    
    func fetchAll() -> Promise<[Polygon]> {
        return Promise { seal in
            let realm = try! Realm()
            let polygons = realm.objects(Polygon.self)
            
            if !polygons.isEmpty {
                seal.fulfill(Array(polygons))
            } else {
                seal.reject(NSError(domain: "Error fetching polygons", code: 400))
            }
        }
    }
    
    func store(polygon: Polygon) throws {
        let realm = try! Realm()
        do {
            try realm.write {
                realm.add(polygon)
            }
        } catch {
            throw NSError(domain: "Error creating polygons", code: 400)
        }
    }
}

