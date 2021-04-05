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
    
    
    @IBOutlet weak var pullUpImgCollection: UICollectionView!
    
    
    var locationManager = CLLocationManager()
//    let authorizationStatus = CLLocationManager.authorizationStatus()
    
    let regionRadius: Double = 1000.0
    var screeSize = UIScreen.main.bounds
    
    var spinner : UIActivityIndicatorView?
    var progressLbl : UILabel?
    
    var flowLayout = UICollectionViewFlowLayout()
//    var collectionView : UICollectionView? // old
    
    
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    var imageTitleArray = [String]()
    var imageDescArray = [String]()
    var imageOwnerArray = [String]()
    var imageDateArray = [String]()
    var imageViewsArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        configureLocationServices()
        addDoubleTap()
        
//        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
//        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
//        collectionView?.delegate = self
//        collectionView?.dataSource = self
//        collectionView?.backgroundColor = #colorLiteral(red: 0.9590949416, green: 0.6425344348, blue: 0.2168852091, alpha: 1)
        
        
        pullUpImgCollection.delegate = self
        pullUpImgCollection.dataSource = self
        pullUpImgCollection.backgroundColor = #colorLiteral(red: 0.9590949416, green: 0.6425344348, blue: 0.2168852091, alpha: 1)
        
//        for 3dtouch peek and pop
        registerForPreviewing(with: self, sourceView: pullUpImgCollection!)
        
//        pullUpView.addSubview(collectionView!)
        pullUpView.addSubview(pullUpImgCollection!)
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
        
//        collectionView?.addSubview(spinner!)
        pullUpImgCollection.addSubview(spinner!)
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
        
//        collectionView?.addSubview(progressLbl!)
        pullUpImgCollection.addSubview(progressLbl!)
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
        imageTitleArray = []
        
//        collectionView?.reloadData()
        pullUpImgCollection.reloadData()
        
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
        
        
        retrieveUrls(forAnnotation: annotation) { (finished) in
//            print(self.imageUrlArray)
            if finished {
                self.retrieveImages { (finished) in
                    if finished {
                        self.resetSpinner()
                        self.removeProgressLbl()
//                        self.collectionView?.reloadData()
                        self.pullUpImgCollection.reloadData()
                        
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
    
    func retrieveUrls(forAnnotation annotation: DroppaplePin, handler: @escaping(_ isSuccess: Bool) -> ()) {
        
        AF.request(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 50)).responseJSON { (response) in
            
//            guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }  // oldway, deprecated in AF 5
            
            switch response.result {
            case .success(let value):
                guard let json = value as? Dictionary<String, AnyObject> else { return }
                
                print("responseJSON ==> \(json)") // need to upgrade of functionality I.E. photo infos.., Title, date uploaded,, etc
                
                let photosDict = json["photos"] as! Dictionary<String, AnyObject>
                let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
                
                for photo in photosDictArray {
                    let postUrl = "https://live.staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_c_d.jpg"
                    
                    let postTitle = "\(photo["title"]!)"
                    
                    let postDesc = "\(photo["description"]!["_content"]! ?? "")"
                    
                    let postDate = "\(photo["datetaken"]!)"
                    
                    let postOwner = "Posted by: \(photo["ownername"]!)"
                    
                    let postViews = "\(photo["views"]!)"
                    
                    
                    
                    self.imageUrlArray.append(postUrl)
                    self.imageTitleArray.append(postTitle)
                    self.imageDescArray.append(postDesc)
                    self.imageDateArray.append(postDate)
                    self.imageOwnerArray.append(postOwner)
                    self.imageViewsArray.append(postViews)
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
                    
                    self.progressLbl?.text = "\(self.imageArray.count)/50 Images downloaded.."
                    
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

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customPhotoCell", for: indexPath) as? CustomPhotoCell else { return UICollectionViewCell() }
        
        let imageFromIndex = imageArray[indexPath.row]
//        let imageView = UIImageView(image: imageFromIndex)
        let imageViewsCount = imageViewsArray[indexPath.row]
        
        cell.pullUpImg.image = imageFromIndex
        cell.pullUpImgViewCounts.text = imageViewsCount
        
        
        cell.contentView.layer.cornerRadius = 5
        cell.contentView.layer.borderWidth = 1.0

        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true

        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else { return }
        
        //        popVC.initData(forImage: imageArray[indexPath.row])
        //        popVC.initData(forImage: imageArray[indexPath.row], forTitle: imageTitleArray[indexPath.row])
        
        popVC.initData(forImage: imageArray[indexPath.row], forTitle: imageTitleArray[indexPath.row], forDesc: imageDescArray[indexPath.row], forPostBy: imageOwnerArray[indexPath.row], forPostDate: imageDateArray[indexPath.row])
        
        present(popVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenSize = UIScreen.main.bounds
        
        return CGSize(width: (screenSize.width / 8) - 5.0, height: (screenSize.width / 8) - 5.0)
//        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 6.0
    }
}

//extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return  1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return imageArray.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
//
//        let imageFromIndex = imageArray[indexPath.row]
//
//        let imageView = UIImageView(image: imageFromIndex)
//
//        cell.addSubview(imageView)
//
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else { return }
//
////        popVC.initData(forImage: imageArray[indexPath.row])
////        popVC.initData(forImage: imageArray[indexPath.row], forTitle: imageTitleArray[indexPath.row])
//
//        popVC.initData(forImage: imageArray[indexPath.row], forTitle: imageTitleArray[indexPath.row], forDesc: imageDescArray[indexPath.row], forPostBy: imageOwnerArray[indexPath.row], forPostDate: imageDateArray[indexPath.row])
//
//        present(popVC, animated: true, completion: nil)
//    }
//}
//


// 3d touch peek and pop


extension MapVC: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = pullUpImgCollection.indexPathForItem(at: location), let cell = pullUpImgCollection?.cellForItem(at: indexPath) else { return nil }
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else { return nil }

//        popVC.initData(forImage: imageArray[indexPath.row])
//        popVC.initData(forImage: imageArray[indexPath.row], forTitle: imageTitleArray[indexPath.row])


        popVC.initData(forImage: imageArray[indexPath.row], forTitle: imageTitleArray[indexPath.row], forDesc: imageDescArray[indexPath.row], forPostBy: imageOwnerArray[indexPath.row], forPostDate: imageDateArray[indexPath.row])

//        previewingContext.sourceRect = cell.contentView.frame
        previewingContext.sourceRect = cell.contentView.frame
        return popVC

    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
