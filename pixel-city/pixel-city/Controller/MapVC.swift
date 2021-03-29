//
//  MapVC.swift
//  pixel-city
//
//  Created by Jeff Umandap on 3/29/21.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
    }


    @IBAction func centerMapBtnPressed(_ sender: Any) {
    }
    
    
}


extension MapVC: MKMapViewDelegate {
    
}
