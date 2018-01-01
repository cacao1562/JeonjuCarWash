

import UIKit
import GoogleMaps

class PanoView : UIViewController, GMSMapViewDelegate {
    
    var lat : Double?
    var lon : Double?
    
    
    override func loadView() {
        
        let panoView = GMSPanoramaView(frame: .zero)
        self.view = panoView
        
        panoView.moveNearCoordinate(CLLocationCoordinate2D(latitude: self.lat!, longitude: self.lon!))
        //         panoView.moveNearCoordinate(CLLocationCoordinate2D(latitude: -33.732, longitude: 150.312))
        let position = CLLocationCoordinate2DMake(self.lat!, self.lon!)
        let marker_streetview = GMSMarker(position: position)
        
        marker_streetview.panoramaView = panoView
        
    }
    
}
