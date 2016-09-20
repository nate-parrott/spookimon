//
//  Morality.swift
//  spookimon
//
//  Created by Nate Parrott on 9/19/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

class Morality {
    static let Shared = Morality()
    // init. good and evil
    init() {
        FIRApp.configure()
        firebase = FIRDatabase.database().reference()
    }
    let firebase: FIRDatabaseReference
}

struct Cell: Hashable {
    let lat: Int
    let lng: Int
    static let latDelta: Double = 0.000153 * 4
    static let lngDelta: Double = 0.000188 * 4
    init(latlng: CLLocationCoordinate2D) {
        lat = Int(floor(latlng.latitude / Cell.latDelta))
        lng = Int(floor(latlng.longitude / Cell.lngDelta))
    }
    init(latCell: Int, lngCell: Int) {
        lat = latCell
        lng = lngCell
    }
    var hashValue: Int {
        return "\(lat) \(lng)".hashValue
    }
    var bucket: String {
        get {
            return "\(Int(lat / 20))_\(Int(lng / 20))"
        }
    }
    static func expandBoundingBox(min: Cell, max: Cell) -> (Cell, Cell) {
        let dx = (max.lat - min.lat)
        let dy = (max.lng - min.lng)
        let newMin = Cell(latCell: min.lat - Int(Float(dx) * 0.3), lngCell: min.lng - Int(Float(dy) * 0.3))
        let newMax = Cell(latCell: max.lat + Int(Float(dx) * 0.3), lngCell: max.lng + Int(Float(dy) * 0.3))
        return (newMin, newMax)
    }
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: Double(lat) * Cell.latDelta, longitude: Double(lng) * Cell.lngDelta)
        }
    }
    var key: String {
        get {
            return "\(lat)+\(lng)"
        }
    }
}

func ==(l: Cell, r: Cell) -> Bool {
    return l.lat == r.lat && l.lng == r.lng
}

class ZoneObservation {
    init(minCell: Cell, maxCell: Cell) {
        self.minCell = minCell
        self.maxCell = maxCell
        var buckets = Set<String>()
        if minCell.lat < maxCell.lat && minCell.lng < maxCell.lng {
            for x in minCell.lat...maxCell.lat {
                for y in minCell.lng...maxCell.lng {
                    let bucket = Cell(latCell: x, lngCell: y).bucket
                    buckets.insert(bucket)
                }
            }
        } else {
            print("minCell's lat or lng isn't less than maxCell's")
        }
        print("Watching buckets \(buckets)")
        let fbRoot = Morality.Shared.firebase.child("buckets")
        databaseReferences = buckets.map({ fbRoot.child($0) })
        for ref in databaseReferences {
            let key = ref.key
            ref.observe(.value, andPreviousSiblingKeyWith: { [weak self] (snapshot, _) in
                if let val = snapshot.value as? [String: AnyObject] {
                    self?.buckets[key] = val
                } else {
                    self?.buckets.removeValue(forKey: key)
                }
                }, withCancel: nil)
        }
    }
    
    let minCell: Cell
    let maxCell: Cell
    
    let databaseReferences: [FIRDatabaseReference]
    
    var buckets = [String: [String: AnyObject]]()
    
    var onUpdate: (() -> ())?
    
    deinit {
        for ref in databaseReferences {
            ref.removeAllObservers()
        }
    }
    
    func contains(min: Cell, max: Cell) -> Bool {
        return min.lat >= self.minCell.lat && min.lng >= self.minCell.lng && max.lat <= self.maxCell.lat && max.lng <= self.maxCell.lng
    }
    
    func spookinessForCell(cell: Cell) -> Float {
        if let c = buckets[cell.bucket], let data = c[cell.key] as? [String: AnyObject], let spookiness = data["spookiness"] as? Float {
            return spookiness
        }
        return noise2d(Float(cell.lat) / 2, Float(cell.lng) / 2)
    }
}
