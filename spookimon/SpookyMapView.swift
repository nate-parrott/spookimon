//
//  SpookyMapView.swift
//  spookimon
//
//  Created by Nate Parrott on 9/19/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SpookyMapView: UIView, MKMapViewDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    let locationManager = CLLocationManager()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    let mapView = MKMapView()
    func setup() {
        addSubview(mapView)
        mapView.delegate = self
        mapView.showsUserLocation = true
        // mapView.isUserInteractionEnabled = false
        mapView.mapType = .satellite
        locationManager.requestWhenInUseAuthorization()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        mapView.frame = bounds
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        mapView.setCenter(userLocation.coordinate, animated: true)
        mapView.setRegion(MKCoordinateRegion.init(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: Cell.latDelta * 8, longitudeDelta: Cell.lngDelta * 8)), animated: false)
        mapRegionUpdated()
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapRegionUpdated()
    }
    func mapRegionUpdated() {
        let r = mapView.visibleMapRect
        let coord1 = MKCoordinateForMapPoint(MKMapPointMake(r.origin.x, r.origin.y))
        let coord2 = MKCoordinateForMapPoint(MKMapPointMake(r.origin.x + r.size.width, r.origin.y + r.size.height))
        let minCoord = CLLocationCoordinate2D(latitude: min(coord1.latitude, coord2.latitude), longitude: min(coord1.longitude, coord2.longitude))
        let maxCoord = CLLocationCoordinate2D(latitude: max(coord1.latitude, coord2.latitude), longitude: max(coord1.longitude, coord2.longitude))
        if maxCoord.latitude - minCoord.latitude < 50 && maxCoord.longitude - minCoord.longitude < 50 {
            mapCoverage = (minCell: Cell(latlng: minCoord), maxCell: Cell(latlng: maxCoord))
        }
    }
    var mapCoverage: (minCell: Cell, maxCell: Cell)? {
        didSet {
            if let (minCell, maxCell) = mapCoverage {
                if let o = observer, o.contains(min: minCell, max: maxCell) {
                    // pass
                } else {
                    let (min, max) = Cell.expandBoundingBox(min: minCell, max: maxCell)
                    observer = ZoneObservation(minCell: min, maxCell: max)
                }
            }
        }
    }
    var observer: ZoneObservation? {
        didSet(old) {
            old?.onUpdate = nil
            observer?.onUpdate = {
                [weak self] in
                self?.updatePolygons()
            }
            updatePolygons()
        }
    }
    func updatePolygons() {
        if let o = observer {
            var overlays = [MKOverlay]()
            for x in o.minCell.lat...o.maxCell.lat {
                for y in o.minCell.lng...o.maxCell.lng {
                    overlays.append(CellOverlay(cell: Cell(latCell: x, lngCell: y)))
                }
            }
            mapView.removeOverlays(mapView.overlays)
            mapView.addOverlays(overlays)
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let cellOverlay = overlay as! CellOverlay
        let renderer = MKPolygonRenderer(polygon: cellOverlay.polygon)
        var spookiness: Float
        if let o = observer {
            let handle = CellHandle(observation: o, cell: cellOverlay.cell)
            spookiness = handle.spookiness
        } else {
            spookiness = 0
        }
        renderer.fillColor = UIColor(hue: 1, saturation: 1, brightness: 1, alpha: CGFloat(spookiness))
        return renderer
    }
}

class CellOverlay: NSObject, MKOverlay {
    init(cell: Cell) {
        self.cell = cell
    }
    let cell: Cell
    var boundingMapRect: MKMapRect {
        get {
            let origin = MKMapPointForCoordinate(cell.coordinate)
            let extent = MKMapPointForCoordinate(Cell(latCell: cell.lat + 1, lngCell: cell.lng + 1).coordinate)
            return MKMapRect(origin: origin, size: MKMapSize(width: extent.x - origin.x, height: extent.y - origin.y))
        }
    }
    var coordinate: CLLocationCoordinate2D {
        let bbox = boundingMapRect
        let ctr = MKMapPointMake(MKMapRectGetMidX(bbox), MKMapRectGetMidY(bbox))
        return MKCoordinateForMapPoint(ctr)
    }
    var polygon: MKPolygon {
        get {
            let bbox = boundingMapRect
            var points = [bbox.origin, MKMapPointMake(bbox.origin.x, bbox.origin.y + bbox.size.height), MKMapPointMake(bbox.origin.x + bbox.size.width, bbox.origin.y + bbox.size.height), MKMapPointMake(bbox.origin.x + bbox.size.width, bbox.origin.y)]
            return MKPolygon(points: &points, count: 4)
        }
    }
}
