//
//  CurrentLocationObserver.swift
//  spookimon
//
//  Created by Nate Parrott on 9/21/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import Foundation
import CoreLocation

class CurrentLocationObserver: NSObject, CLLocationManagerDelegate {
    override init() {
        super.init()
        locationMgr.delegate = self
        locationMgr.requestWhenInUseAuthorization()
        locationMgr.startUpdatingLocation()
    }
    let locationMgr = CLLocationManager()
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
    }
    var currentLocation: CLLocation? {
        didSet {
            if let loc = currentLocation {
                cell = Cell(latlng: loc.coordinate)
            }
        }
    }
    var cell: Cell? {
        didSet(old) {
            if cell != old {
                if let c = cell, observer == nil || !observer!.contains(min: c, max: c) {
                    observer = ZoneObservation(minCell: Cell(latCell: c.lat - 2, lngCell: c.lng - 2), maxCell: Cell(latCell: c.lat + 2, lngCell: c.lng + 2))
                }
                if let o = observer, let c = cell {
                    cellHandle = CellHandle(observation: o, cell: c)
                    print("Handle: \(cellHandle)")
                }
                if let cb = onUpdate { cb() }
            }
        }
    }
    var observer: ZoneObservation? {
        didSet(old) {
            print("Observer: \(observer)")
            old?.onUpdate = nil
            observer?.onUpdate = {
                [weak self] in
                if let cb = self?.onUpdate { cb() }
            }
        }
    }
    var cellHandle: CellHandle?
    var onUpdate: (() -> ())?
}
