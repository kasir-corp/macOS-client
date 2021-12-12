//
//  HeatMapViewModel.swift
//  MacOSMap
//
//  Created by Jackie Leonardy on 27/10/21.
//

import SwiftUI
import MapKit


struct MapCompat : NSViewRepresentable {
    @Binding var coordinateRegion : MKCoordinateRegion
    @Binding var touchPoint: NSPoint
    
    @ObservedObject var viewModel: TrendingProvinceViewModel
    var mapView = MKMapView()
    
    func makeNSView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        mapView.region = coordinateRegion

        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 10000000)
        mapView.setCameraZoomRange(zoomRange, animated: false)
        
        mapView.showsZoomControls = true
        mapView.showsTraffic = true
        
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        
        loadMapOverlay()
        return mapView
    }
    
    func updateNSView(_ view: MKMapView, context: Context) {
        DispatchQueue.main.async {
            view.region = coordinateRegion
            context.coordinator.touchPoint = touchPoint
            context.coordinator.mapView(view, regionDidChangeAnimated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, touchPoint: self.$touchPoint, provinces: self.$viewModel.provincesAllTrending)
    }
    
    func render(overlay: MKOverlay, info: Any?) {
        if let polygonInfo = info as? PolygonInfo {
            overlayer.shared.changePolygon(newPolygon: polygonInfo)
        }
        let newMapOverlay = MapOverlayer(overlay: overlay, polygonInfo: overlayer.shared.polygonInfo, isHover: false)
        MapOverlays.shared.addOverlay(mapOverlayer: newMapOverlay)
        MapOverlays.shared.addTempOverlay(mapOverlayer: overlay)
        self.mapView.addOverlay(overlay)
        self.mapView.setVisibleMapRect(overlay.boundingMapRect, animated: true)
    }
    
    class Coordinator : NSObject, MKMapViewDelegate {
        var parent : MapCompat
        let tempOverlayers = MapOverlays.shared
        @Binding var provincesAllTrending: [ProvinceTrendingModel]
        @Binding var touchPoint: NSPoint
        
        init(_ parent: MapCompat, touchPoint: Binding<NSPoint>, provinces: Binding<[ProvinceTrendingModel]>) {
            self.parent = parent
            self._touchPoint = touchPoint
            self._provincesAllTrending = provinces
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            DispatchQueue.main.async {
                self.parent.coordinateRegion = mapView.region
                self.touchPoint = self.parent.touchPoint
                self.provincesAllTrending = self.parent.viewModel.provincesAllTrending
            }
        }
        
        func render(_ mapView: MKMapView, overlay: MKOverlay, info: Any?, isHover: Bool) {
            var intersectData : PolygonInfo
            
            if (info as? PolygonInfo) != nil {
                intersectData = info as! PolygonInfo
                if isHover {
                    let data = info as! PolygonInfo
                    intersectData.isIntersect = true
                    print("INTERSECT! with \(data.propinsi) on \(overlay.coordinate)")
//                    parent.viewModel.isIntersect = true
                }
                overlayer.shared.changePolygon(newPolygon: intersectData)
//                parent.viewModel.isIntersect = false
            }
            
            mapView.addOverlay(overlay)
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            var overlayers = MapOverlays.shared.returnOverlayList()
            
            let fummy = mapView.convert(NSPoint(x: self.touchPoint.x, y: self.touchPoint.y), toCoordinateFrom: mapView)
            let maprect = MKMapRect(origin: MKMapPoint(fummy), size: MKMapSize(width: 0.0001, height: 0.0001))
            var index = 0

            for overlayMap in mapView.overlays {
                if overlayMap.boundingMapRect.intersects(maprect)  {
                    let polygon = overlayers[index].overlay as? MKPolygon
                    let renderer = MKPolygonRenderer(polygon: polygon!)
                    renderer.fillColor = NSColor(red: 255/255, green: 215/255, blue: 255/255, alpha: 1)
                    mapView.exchangeOverlay(overlayMap, with: overlayers[index].overlay)
                    overlayers[index].isHover = true
        
                    tempOverlayers.addTempOverlay(mapOverlayer: polygon!)
                    print(overlayMap.title!!)
                    print("\(overlayMap.subtitle!!) Kasus")
                }
                index += 1
            }
            
            for overlayer in overlayers {
                self.render(mapView, overlay: overlayer.overlay, info: overlayer.polygonInfo, isHover: overlayer.isHover)
            }
            
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
                if annotation is MKUserLocation { return nil }

                let reuseIdentifier = "..."

                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

                if annotationView == nil {
                    annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                } else {
                    annotationView?.annotation = annotation
                }

                return annotationView
            }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon {
                
                let renderer = MKPolygonRenderer(polygon: polygon)
                
                for datas in provincesAllTrending {
                    if overlayer.shared.polygonInfo.kode == datas.id {
                        overlayer.shared.polygonInfo.jumlah = datas.news_count
                        break
                    }
                }
                if overlayer.shared.polygonInfo.isIntersect {
                    renderer.fillColor = NSColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
                } else {
                    if overlayer.shared.polygonInfo.jumlah == 0 {
                        renderer.fillColor = NSColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 0.5)
                    }
                    else if overlayer.shared.polygonInfo.jumlah > 0 && overlayer.shared.polygonInfo.jumlah < 100 {
                        renderer.fillColor = NSColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 0.5)
                    }
                    
                    else if overlayer.shared.polygonInfo.jumlah > 99 && overlayer.shared.polygonInfo.jumlah < 300 {
                        renderer.fillColor = NSColor(red: 255/255, green: 174/255, blue: 66/255, alpha: 0.5)
                    }
                    
                    else if overlayer.shared.polygonInfo.jumlah > 300 {
                        renderer.fillColor = NSColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.5)
                    }
                    else if overlayer.shared.polygonInfo.jumlah == -1 {
                        renderer.fillColor = NSColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
                    }
                }
                renderer.strokeColor = NSColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.3)
                renderer.lineWidth = 1
                
                renderer.polygon.title = overlayer.shared.polygonInfo.propinsi
                renderer.polygon.subtitle = "\(overlayer.shared.polygonInfo.jumlah)"
                return renderer
            }
            
            if let tileOverlay = overlay as? MKTileOverlay {
               return MKTileOverlayRenderer(tileOverlay: tileOverlay)
           } else {
               return MKPolygonRenderer(overlay: overlay)
           }
        }
    }
}

class CustomAnnotationView: MKPinAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        canShowCallout = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - Reading and Writing JSON File
extension MapCompat {
    func loadMapOverlay() {
        if !MapOverlays.shared.returnTempOverlay().isEmpty {
            mapView.addOverlays(MapOverlays.shared.returnTempOverlay())
        } else {
            loadGeoJson()
        }
    }
    private func loadGeoJson() {
        guard let url = Bundle.main.url(forResource: "IndonesiaGeoJSONProvinces", withExtension: "geojson") else {
            fatalError("unable to get geojson")
        }
        
        var geoJson = [MKGeoJSONObject]()
        var overlays = [MKOverlay]()
        
        do {
            let data = try Data(contentsOf: url)
            geoJson = try MKGeoJSONDecoder().decode(data)
        } catch {
            fatalError("Unable to decode JSON")
        }

        for item in geoJson {
            if let feature = item as? MKGeoJSONFeature {
                let geometry = feature.geometry.first
                let propData = feature.properties!
                
                if let polygon = geometry as? MKPolygon {
                    let polygonInfo = try? JSONDecoder.init().decode(PolygonInfo.self, from: propData)
                    self.render(overlay: polygon, info: polygonInfo)
                }
                
                for geo in feature.geometry {
                    if let polygon = geo as? MKPolygon {
                        overlays.append(polygon)
                    }
                }
            }
        }
    }
}

// MARK: - Annotation Maker Function
extension MapCompat {
    func makeCallout(namaProvinsi: String, jumlah: Int){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinateRegion.center
        annotation.title = "\(namaProvinsi): \(jumlah) kasus"
        mapView.addAnnotation(annotation)
    }
}

// MARK: - Configuring Google style Overlay
extension MapCompat {
    private func configureTileOverlay() {
            guard let overlayFileURLString = Bundle.main.path(forResource: "GoogleStyle", ofType: "json") else {
                    return
            }

        let overlay = MKTileOverlay.init(urlTemplate: overlayFileURLString)
                overlay.isGeometryFlipped = false
                overlay.canReplaceMapContent = true
        mapView.addOverlay(overlay, level: MKOverlayLevel.aboveLabels)
    }
}
