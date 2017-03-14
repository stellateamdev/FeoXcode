//
//  ViewController.swift
//  MapKitTutorial
//
//  Created by Robert Chen on 12/23/15.
//  Copyright © 2015 Thorn Technologies. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
protocol HandleMapSearch: class {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class MapSearchViewController: UIViewController {
    
    var selectedPin: MKPlacemark?
    var resultSearchController: UISearchController!
    var search = false
    let locationManager = CLLocationManager()
    var searchResults = MKLocalSearchCompletion()
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentlocation:UIButton!
     @IBOutlet weak var pin: UIImageView!
    @IBOutlet weak var locationDetail:UILabel!
    var rightButton = UIBarButtonItem()
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationDetail.backgroundColor = UIColor.white
      mapView.showsUserLocation = false
      
     let path = UIBezierPath(roundedRect:CGRect(x: locationDetail.bounds.minX-3, y: locationDetail.bounds.minY-2, width: locationDetail.bounds.width+6, height: locationDetail.bounds.height+6), cornerRadius: 0).cgPath
        locationDetail.layer.shadowColor = UIColor.darkGray.cgColor
        locationDetail.layer.shadowOffset = CGSize(width: 0, height: 0)
        locationDetail.layer.shadowRadius = 6
        locationDetail.layer.shadowOpacity = 0.4
        locationDetail.layer.shadowPath = path
        mapView.delegate = self
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.tintColor = UIColor.stellaPurple()
        searchBar.placeholder = "Search Location "
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.placeholder = "Search for places"
        
        pin.backgroundColor = UIColor.clear
        pin.isUserInteractionEnabled = false
        navigationItem.titleView = resultSearchController?.searchBar
        let leftButton = UIBarButtonItem(image: UIImage(named:"Delete")?.withRenderingMode(.alwaysTemplate), style: .plain, target:self, action: #selector(MapSearchViewController.closeView))
       leftButton.tintColor = UIColor.stellaPurple()
         rightButton =  UIBarButtonItem(title:"Select", style: .plain, target:self, action: #selector(MapSearchViewController.setLocation))
        rightButton.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "HelveticaNeue-Medium", size: 17.0)!], for: .normal)
        rightButton.tintColor = UIColor.stellaPurple()
        leftButton.tintColor = UIColor.stellaPurple()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "DefineLocationFilled")?.withRenderingMode(.alwaysTemplate)
        attachment.bounds = CGRect(x:0,y:-7.0, width:attachment.image!.size.width-5, height:attachment.image!.size.height-5)
        let attachmentString = NSAttributedString(attachment: attachment)
        let str2 = NSMutableAttributedString(string: " Set location", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size:22.0)!])
        let str = NSMutableAttributedString(string: " ")
        
        str.append(attachmentString)
        str.append(str2)
        
        currentlocation.setImage(UIImage(named:"DefineLocation")?.withRenderingMode(.alwaysTemplate), for: .normal)
        currentlocation.backgroundColor = UIColor.stellaPurple()
        currentlocation.tintColor = UIColor.white
        currentlocation.layer.cornerRadius = currentlocation.frame.size.width/2.0
        currentlocation.layer.shadowColor = UIColor.black.cgColor
        currentlocation.layer.shadowOpacity = 0.8
        currentlocation.layer.shadowOffset = CGSize.zero
        currentlocation.layer.shadowRadius = 3

        
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
    }
    
    func getDirections(){
        guard let selectedPin = selectedPin else { return }
        let mapItem = MKMapItem(placemark: selectedPin)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func currentLocation() {
        self.mapView.setCenter(self.mapView.userLocation.coordinate, animated: true)
        let newPoint = self.mapView.convert(mapView.centerCoordinate, toPointTo: self.view)
        pin.center.x = newPoint.x
        pin.center.y = newPoint.y
    }
    func setLocation() {
        let data = ["location":mapView.centerCoordinate,"locationAddress":self.locationDetail.text!] as [String : Any]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setLocation"), object: nil, userInfo: data)
        self.closeView()

        }
    }


extension MapSearchViewController : CLLocationManagerDelegate {
    
     func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        if location.coordinate.latitude == mapView.userLocation.coordinate.latitude && location.coordinate.longitude == mapView.userLocation.coordinate.longitude {
        let newPoint = self.mapView.convert(mapView.centerCoordinate, toPointTo: self.view)
      // pin.center.x = newPoint.x
       // pin.center.y = newPoint.y
        }
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        print("region \(region) \(location.coordinate) \(span)")
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }

}
extension MapSearchViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        search = true
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
                annotation.subtitle = "\(city) \(state)"
        }
        
       // mapView.addAnnotation(annotation)
        
        self.mapView.selectAnnotation(annotation, animated: false)
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        print("\n hello 1 \(placemark.coordinate) \n")
        
        let newPoint = self.mapView.convert(placemark.coordinate, toPointTo: self.view)
        pin.center.x = newPoint.x
        pin.center.y = newPoint.y+15
        mapView.setRegion(region, animated: true)
    }
    
}
extension MapSearchViewController:UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        navigationItem.rightBarButtonItem = rightButton
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        navigationItem.rightBarButtonItem = rightButton
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        navigationItem.rightBarButtonItem = nil
    }
}
extension MapSearchViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
       
        guard !(annotation is MKUserLocation) else { return nil }
       
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
           // pin.isHidden = true
            pinView?.image = UIImage(named: "MarkerFilled")

            
        }
        pinView?.image = UIImage(named:"MarkerFilled")
        
        return pinView
    }
   func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if !search {
            let newPoint = self.mapView.convert(mapView.centerCoordinate, toPointTo: self.view)
           // pin.center.x = newPoint.x
           // pin.center.y = newPoint.y
        }
        else {
            search = false
        }

    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if !search {
            self.locationDetail.text = ""
            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            spinner.color = UIColor.gray
            spinner.frame = CGRect(x: self.view.frame.size.width/2.0-17.5, y:self.locationDetail.frame.size.height/2.0-17.5, width:35 , height: 35)
            locationDetail.addSubview(spinner)
             spinner.startAnimating()
            let centerlocation = mapView.centerCoordinate
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: centerlocation.latitude, longitude: centerlocation.longitude)
            
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placemarks?[0]
                var str = " 🚩 "
                // Address dictionary
               // print(placeMark.addressDictionary ?? "")
                
                // Location name
                if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                    str+="\(locationName),"
                }
                
                // Street address
                if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                    str+=" \(street),"
                }
                
                // City
                if let city = placeMark.addressDictionary!["City"] as? NSString {
                    str+=" \(city),"
                }
                
                // Zip code
                if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                    str+=" \(zip),"
                }
                
                // Country
                if let country = placeMark.addressDictionary!["Country"] as? NSString {
                    str+=" \(country)"
                }
                self.locationDetail.text = str
                spinner.stopAnimating()
                spinner.removeFromSuperview()
                
                
                
            })
        }
        }
        
    }
    

