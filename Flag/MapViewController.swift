//
//  MapViewController.swift
//  Flag
//
//  Created by marky RE on 11/25/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class MapViewController: UIViewController {
@IBOutlet var mapView: MKMapView!
    var currentLocation = UIButton()
    let manager = CLLocationManager()
    var geoFire:GeoFire!
    var geoFireRef:FIRDatabaseReference!
    //var imageView = UIImageView()
    var isClick = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("check the tabbar height 2 \(self.tabBarController?.tabBar.frame.size.height)")
        tabbarHeight = self.tabBarController?.tabBar.frame.size.height
        currentLocation.tintColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        currentLocation.setImage(UIImage.init(named: "DefineLocation")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        
        currentLocation.backgroundColor = UIColor.stellaPurple()
        currentLocation.frame = CGRect(x:self.view.frame.size.width-55, y: self.view.frame.maxY-tabbarHeight!-150, width: 46, height: 46)
        currentLocation.layer.shadowColor = UIColor.black.cgColor
        currentLocation.layer.shadowOpacity = 0.34
        currentLocation.layer.shadowOffset = CGSize.zero
        currentLocation.layer.shadowRadius = 3
        currentLocation.layer.cornerRadius = currentLocation.frame.size.height/2.0
        
    }
    func setFriendCenter(noti:Notification) {
        let data = noti.userInfo?["data"] as! User
        print("what the fuck is going \(data.latitude)")
        let center =  CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(data.latitude)), longitude:  CLLocationDegrees(Double(data.longitude)))
        mapView.centerCoordinate = center
        //imageView.center = self.mapView.convert(mapView.centerCoordinate, toPointTo: self.mapView)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.05))
        
        self.mapView.setRegion(region, animated: true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if FIRAuth.auth()?.currentUser != nil {
            currentUser.id = FIRAuth.auth()!.currentUser!.uid
        }
        checkIfLogin()
        mapView.delegate = self
        viewHeight = self.view.frame.size.height
        tabbarHeight = self.tabBarController?.tabBar.frame.size.height
         let application = UIApplication.shared
        if application.applicationIconBadgeNumber != 0 {
            self.tabBarController?.tabBar.items?[2].badgeValue = "\(application.applicationIconBadgeNumber)"
        }
       
       /* imageView = UIImageView.init(image: UIImage.init(named: "MarkerFilled"))
        let newPoint = self.mapView.convert(mapView.centerCoordinate, toPointTo: self.mapView)
        print("test coordinate \(newPoint)  \(self.view.center)")
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = UIViewContentMode.center
        imageView.center.x = newPoint.x
        imageView.center.y = newPoint.y
        self.view.addSubview(imageView) */
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        mapView.userTrackingMode = .follow
        manager.startUpdatingLocation()
        
       // geoFireRef = FIRDatabase.database().reference()
       // geoFire = GeoFire(firebaseRef: geoFireRef!)
        observeNotification()
         currentLocation.addTarget(self, action: #selector(MapViewController.locateCurrent), for: .touchUpInside)
         addBottomSheetView()
    }
    func checkIfLogin() {
        if FIRAuth.auth()?.currentUser == nil {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "login") as! LoginController
            self.present(controller, animated: true, completion: nil)
            return
        }
        FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
            if user == nil {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "login") as! LoginController
                self.present(controller, animated: true, completion: nil)
            }
            else {
                FIRDatabase.database().reference().child("Users/\(currentUser.id)").observeSingleEvent(of: .value, with: {(snap) in
                    if snap.value is NSNull {
                        let view = self.storyboard?.instantiateViewController(withIdentifier: "setUsername") as! SetUserNameViewController
                        self.navigationController?.pushViewController(view, animated: true)
                    }else{
                        let dict = snap.value as! NSDictionary
                        print(dict)
                        if dict["username"] == nil {
                            let view = self.storyboard?.instantiateViewController(withIdentifier: "setUsername") as! SetUserNameViewController
                            self.navigationController?.pushViewController(view, animated: true)
                        }
                    }
                })
            }
        }
    }
    func observeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.createFriendAnnotation(noti:)), name: NSNotification.Name(rawValue: "createFriendAnnotation"), object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.removeFriendAnnotation), name: NSNotification.Name(rawValue: "removeFriendAnnotation"), object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.updateFriendAnnotation(user:)), name: NSNotification.Name(rawValue: "updateFriendAnnotation"), object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.showFriendAnnotation(user:)), name: NSNotification.Name(rawValue: "showFriendAnnotation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.setFriendCenter(noti:)), name: NSNotification.Name(rawValue: "tapFriendLocation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.updateDisplay(noti:)), name: NSNotification.Name(rawValue: "updateProfile"), object: nil)
       
    }
    
    func createFriendAnnotation(noti:NSNotification) {
        if  noti.userInfo != nil {
            print("hey motherfucker anno")
            let data = noti.userInfo as! [String:User]
            for value in data {
                print("YEAH CREATE FUCK \(data) \(value.value.username)")
                createFriendAnnotation(user:value.value)
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkLocationAuthorizationStatus()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func checkLocationAuthorizationStatus() {
        print("enter authorize check)")
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways { print("what89999")}
        else {
            
            if CLLocationManager.authorizationStatus() == .notDetermined {
                manager.requestAlwaysAuthorization()
            }
            else {
                let alertController = UIAlertController(title: "Background Location Access Disabled", message: "In order to access your location, Allow location services.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: "Settings", style: .`default`, handler: { action in
                    if #available(iOS 10.0, *) {
                        let settingsURL = URL(string: UIApplicationOpenSettingsURLString)!
                        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                    } else {
                        if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.openURL(url as URL)
                        }
                    }
                }))
                self.present(alertController, animated: true, completion: nil)
            }

        }
    }




}
extension MapViewController {
    func addBottomSheetView() {
        // 1- Init bottomSheetVC
        let bottomSheetVC = self.storyboard?.instantiateViewController(withIdentifier: "Friendlist") as! FriendListViewController
        // bottomSheetVC.view.frame = CGRect(x:0, y:self.view.frame.height-(self.tabBarController?.tabBar.frame.height)!-158, width:self.view.frame.width, height:self.view.frame.height)
        // 2- Add bottomSheetVC as a child view
        bottomSheetVC.view.layer.cornerRadius = 5.0
        self.addChildViewController(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        mapView.addSubview(currentLocation)
        
        bottomSheetVC.didMove(toParentViewController: self)
        
        
        // 3- Adjust bottomSheet frame and initial position.
        
    }
}
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            mapView.showsUserLocation = true
            mapView.centerCoordinate = mapView.userLocation.coordinate
            FIRDatabase.database().reference().child("Users/\(currentUser.id)").updateChildValues(["Latitude":"\(mapView.centerCoordinate.latitude)","Longitude":"\(mapView.centerCoordinate.longitude)"])
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last! as CLLocation
            if loc.coordinate.latitude == self.mapView.userLocation.coordinate.latitude && loc.coordinate.longitude == self.mapView.userLocation.coordinate.longitude {
                let center = CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
                self.mapView.setCenter(center, animated: true)
                //imageView.center = self.mapView.convert(mapView.centerCoordinate, toPointTo: self.mapView)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.05))
                
                self.mapView.setRegion(region, animated: true)
                         FIRDatabase.database().reference().child("Users/\(currentUser.id)").updateChildValues(["Latitude":"\(mapView.centerCoordinate.latitude)","Longitude":"\(mapView.centerCoordinate.longitude)"])
                        //manager.stopUpdatingLocation()
            }
    }
}

extension MapViewController:MKMapViewDelegate {
    
    func locateCurrent() {
        currentLocation.setImage(UIImage.init(named: "DefineLocationFilled"), for: .normal)
        isClick = true
        print("check curernt location \(mapView.userLocation.coordinate)")
        mapView.centerCoordinate = mapView.userLocation.coordinate
        FIRDatabase.database().reference().child("Users/\(currentUser.id)").updateChildValues(["Latitude":"\(mapView.centerCoordinate.latitude)","Longitude":"\(mapView.centerCoordinate.longitude)"])
        currentUser.location = mapView.userLocation.coordinate
        currentUser.latitude = mapView.userLocation.coordinate.latitude
        currentUser.longitude = mapView.userLocation.coordinate.longitude
        //self.createFriendAnnotation(user: currentUser)
        
    }
    func updateDisplay(noti:Notification) {
        print("enter updateDisplay \(noti.userInfo)")
              let user = noti.userInfo?["data"] as! User
        for anno in self.mapView.annotations {
            if anno.title! == user.id {
                let view = self.mapView.view(for: anno)
                if view == nil {
                    return
                }
                for sub in (view?.subviews)! {
                    if sub.isKind(of: UIImageView.self) {
                        print("sub fucking view")
                        let imageView = sub as! UIImageView
                        imageView.image = user.profile
                    }
                
                }
            }
        }
    }
    func createFriendAnnotation(user:User) {
        let annotation = MKPointAnnotation()
        let annoArray = mapView.annotations
          print("add 3 annotation \(self.mapView.annotations)")
       for anno in annoArray {
            if anno.title! == user.id {
                self.mapView.removeAnnotation(anno)
            }
        }
        print("create it bitch \(user.username)")
        annotation.coordinate = CLLocationCoordinate2D(latitude: Double(user.latitude), longitude: Double(user.longitude))
        annotation.title = "\(user.id)"
        annotation.subtitle = " "
        self.mapView.addAnnotation(annotation)
        print("add 2 annotation \(self.mapView.annotations)")
      //  geoFire.setLocation(CLLocation(latitude:Double(user.latitude)!,longitude: Double(user.longitude)!), forKey: user.id)
        
    }
    func updateFriendAnnotation(user:User) {
        for pin in self.mapView.annotations {
            if pin.title! == user.id  {
                let annotation = pin as! MKPointAnnotation
                annotation.coordinate = CLLocationCoordinate2D(latitude: Double(user.latitude), longitude: Double(user.longitude))
                self.mapView.removeAnnotation(pin)
                self.mapView.addAnnotation(annotation)

            }
        }
        //geoFire.removeKey(user.id)
        //   geoFire.setLocation(CLLocation(latitude:Double(user.latitude)!,longitude: Double(user.longitude)!), forKey: user.id)
    }
    func removeFriendAnnotation(noti:Notification) {
       let data = noti.userInfo?["data"] as! User
        for pin in self.mapView.annotations {
            if pin.title! == data.id {
                mapView.removeAnnotation(pin)
            }
        }
    }
    func updateCurrentLocation(){
        let annotation = MKPointAnnotation()
        for pin in self.mapView.annotations {
            if pin.title! == currentUser.id {
                self.mapView.removeAnnotation(pin)
                break
            }
        }
        annotation.coordinate = CLLocationCoordinate2D(latitude: 13.7, longitude: 100.5)
        annotation.title = "\(currentUser.id)"
        annotation.subtitle = " "
        mapView.addAnnotation(annotation)
        mapView.centerCoordinate = annotation.coordinate
        print("S")
    }
    
    func showFriendAnnotation(user:User){
        //mapView.setCenter(CLLocationCoordinate2DMake(Double(user.latitude), Double(user.longitude)), animated: true)
    }
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if isClick == false {
            currentLocation.setImage(UIImage.init(named: "DefineLocation"), for: .normal)
        }
        else {
            isClick = false
        }
        
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView:MKAnnotationView?
        
        annotationView?.canShowCallout = false
        print("hey fucker it's view time")
         print("fuck yeah annotationview \(self.mapView.annotations)")
        if annotation.isKind(of: MKUserLocation.self) {
            print("iskind is mkuserlocation?")
           return nil

        }
        else {
           
            annotationView = MKAnnotationView(annotation:annotation,reuseIdentifier:annotation.title!)
        for value in userArray {
             print("equally likely \(value.latitude ) \(annotation.coordinate.latitude ) \(User().printDict(user: value))")
            if value.id == annotation.title! {
                print("equally likely2 \(value.latitude ) \(annotation.coordinate.latitude ) \(value.profile)")
                
                    print("in for last round \(value.profile)")
                annotationView?.image = UIImage(named:"marker")?.withRenderingMode(.alwaysTemplate)
                annotationView?.tintColor = UIColor.white
                if let img = FriendListViewController.imageCache.object(forKey: NSString(string: value.id)) {
                    print("check img \(img)")
                    annotationView?.addSubview(profileImageView(image: img))
                } else {
                    print("img is not good \( FriendListViewController.imageCache)")
                    if value.thumbnailURL != "" {
                        if let list = UserDefaults.standard.object(forKey: value.id) as? Data {
                            let img = NSKeyedUnarchiver.unarchiveObject(with: list) as! UIImage
                            annotationView?.addSubview(profileImageView(image: img))
                        }else{
                            annotationView?.addSubview(profileImageView(image: UIImage(named:"trump")!))
                        }
                        let ref = FIRStorage.storage().reference(withPath: "profilethumbnails/\(value.id).png")
                        ref.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                            if error != nil {
                                print("JESS: Unable to download image from Firebase storage")
                            } else {
                                print("JESS: Image downloaded from Firebase storage")
                                if let imgData = data {
                                    if let img = UIImage(data: imgData) {
                                        annotationView?.addSubview(self.profileImageView(image: img))
                                        User().setProfileImageOffline(image: img,key:value.id)
                                        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "updateProfile"), object: nil, userInfo:["data":value])
                                        FriendListViewController.imageCache.setObject(img, forKey: NSString(string: value.id))
                                    }
                                }
                            }
                        })
                        
                    }
                    else {
                        annotationView?.addSubview(profileImageView(image: UIImage(named:"trump")!))
                    }
                }
                
        }
            }
        }
        
        print("print it motherfucker anootationaview \(mapView.centerCoordinate) \(annotation.coordinate)")
        return annotationView!
    }
    func profileImageView(image:UIImage) -> UIImageView {
         let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x: 3.5, y: 5, width: 50, height: 50)
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
       return imageView

    }
}
