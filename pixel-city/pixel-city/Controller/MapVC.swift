//
//  MapVC.swift
//  pixel-city
//
//  Created by Jeff Umandap on 3/29/21.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pullUpView: UIView!
    
    
    
    var locationManager = CLLocationManager()
//    let authorizationStatus = CLLocationManager.authorizationStatus()
    
    let regionRadius: Double = 1000.0
    var screeSize = UIScreen.main.bounds
    
    var spinner : UIActivityIndicatorView?
    var progressLbl : UILabel?
    
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView : UICollectionView?
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        configureLocationServices()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        collectionView?.backgroundColor = #colorLiteral(red: 0.9590949416, green: 0.6425344348, blue: 0.2168852091, alpha: 1)
        
        pullUpView.addSubview(collectionView!)
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipeDown.direction = .down
        pullUpView.addGestureRecognizer(swipeDown)
    }
    
    func animateViewUp() {
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown() {
        cancelAllSessions()
        
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screeSize.width / 2) - ((spinner?.frame.width)! / 2), y: 140)
        spinner?.style = UIActivityIndicatorView.Style.large
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        
        collectionView?.addSubview(spinner!)
    }
    
    func resetSpinner(){
        if spinner != nil{
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLbl() {
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screeSize.width / 2) - 120, y: 155, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 14)
        progressLbl?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLbl?.textAlignment = .center
//        progressLbl?.text = "12/40 PHOTOS LOADED"
        
        collectionView?.addSubview(progressLbl!)
    }
    
    func removeProgressLbl() {
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
    }

    @IBAction func centerMapBtnPressed(_ sender: Any) {
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
    
}


extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppaplePin")
        
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9411764706, green: 0.5764705882, blue: 0.168627451, alpha: 1)
        pinAnnotation.animatesDrop = true
        
        return pinAnnotation
    }
    
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        
        
//        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0) // old used in devslope
        
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
        removePin()
        resetSpinner()
        removeProgressLbl()
        
        cancelAllSessions()
        
        imageUrlArray = []
        imageArray = []
        
        collectionView?.reloadData()
        
        addSwipe()
        addSpinner()
        addProgressLbl()
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
//        print(touchCoordinate)
        let annotation = DroppaplePin(coordinate: touchCoordinate, identifier: "droppaplePin")
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        
        mapView.setRegion(coordinateRegion, animated: true)
        
        animateViewUp()
        
//        print(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40))
        
        
        retriveUrls(forAnnotation: annotation) { (finished) in
//            print(self.imageUrlArray)
            if finished {
                self.retrieveImages { (finished) in
                    if finished {
                        self.resetSpinner()
                        self.removeProgressLbl()
                        self.collectionView?.reloadData()
                        
                        //hide spinner
                        //hide label
                        //reload collection view
                    }
                }
            }
        }
        
    }
    
    func removePin() {
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
    }
    
    func retriveUrls(forAnnotation annotation: DroppaplePin, handler: @escaping(_ isSuccess: Bool) -> ()) {
        
        AF.request(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            
//            guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }  // oldway, deprecated in AF 5
            
            switch response.result {
            case .success(let value):
                guard let json = value as? Dictionary<String, AnyObject> else { return }
                let photosDict = json["photos"] as! Dictionary<String, AnyObject>
                let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
                
                for photo in photosDictArray {
                    let postUrl = "https://live.staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_c_d.jpg"
                    self.imageUrlArray.append(postUrl)
                }
                
                handler(true)
            case .failure(let error):
                print(error)
                
                handler(false)
            }
        }
    }
    
    func retrieveImages(handler: @escaping(_ isSuccess: Bool) -> ()) {
        
        for url in imageUrlArray {
            AF.request(url).responseImage { (response) in
                
                switch response.result {
                case .success(let value):
                    let image = value
                    self.imageArray.append(image)
                    
                    self.progressLbl?.text = "\(self.imageArray.count)/40 Images downloaded.."
                    
                    if self.imageArray.count == self.imageUrlArray.count {
                        handler(true)
                    }
                    
                case .failure(let error):
                    print(error)
                    handler(false)
                }
            }
        }
    }
    
    func cancelAllSessions() {
        Alamofire.Session.default.cancelAllRequests()
    }
    
}

extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        centerMapOnUserLocation()
    }
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        
        let imageFromIndex = imageArray[indexPath.row]
        
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else { return }
        popVC.initData(forImage: imageArray[indexPath.row])
        
        present(popVC, animated: true, completion: nil)
    }
    
     
}
