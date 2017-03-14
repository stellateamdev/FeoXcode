//
//  User.swift
//  LopeTalk
//
//  Created by MACBOOK PRO on 10/28/2559 BE.
//  Copyright © 2559 Stella. All rights reserved.
//

import Foundation
import Firebase
import MapKit
class User:NSObject, NSCoding {
    private var  _id:String?
    private var _oneid:String?
    private var _username:String?
    private var _email:String?
    private var _profile:UIImage?
    private var _location:CLLocationCoordinate2D?
    private var _latitude:Double?
    private var _longitude:Double?
    private var _online:Bool?
    private var _pictureURL:String?
    private var _thumbnailURL:String?
    private var _phoneNumber:String?
    private var _editName:String?
    var editName:String {
    get {
    if _editName == nil {
    return ""
    }
    return _editName!
    }
    set {
    _editName = newValue
    }
    }
    var id:String {
        get {
            if _id == nil {
                _id = "test"
                return _id!
            }
            else {
            return _id!
            }
        }
        set {
            _id = newValue
        }
    }
    var thumbnailURL:String {
        get {
            if _thumbnailURL == nil {
                _thumbnailURL = ""
                return _thumbnailURL!
            }
            else {
                return _thumbnailURL!
            }
        }
        set {
            _thumbnailURL = newValue
        }
    }
    var oneid:String {
        get {
            if _oneid == nil {
                _oneid = "test"
                return _oneid!
            }
            else {
                return _oneid!
            }
        }
        set {
            _oneid = newValue
        }
    }
    var username:String {
        get {
            if _username == nil {
                _username = ""
                return _username!
            }
            else {
                return _username!
            }
        }
        set {
            _username = newValue
        }
    }
    var email:String {
        get {
            if _email == nil {
                _email = "email"
                return _email!
            }
            else {
            return _email!
            }
        }
        set {
            _email = newValue
        }
    }
    var location:CLLocationCoordinate2D {
        get {
            if _location == nil {
                return CLLocationCoordinate2D()
            }
            return _location!
        }
        set {
            _location = newValue
        }
        
    }
    var profile:UIImage {
        get {
            if _profile == nil {
                return UIImage(named:"trump")!
            }
            return _profile!
        }
        set {
            _profile = newValue
        }
    }
    var latitude:Double {
        get {
            if _latitude == nil {
                return 0.0
            }
            return _latitude!
        }
        set {
            _latitude = newValue
        }
    }
    var longitude:Double {
        get {
            if _longitude == nil {
                return 0.0
            }
           return _longitude!
        }
        set {
            _longitude = newValue
        }
    }
    var online:Bool {
        get {
            return _online!
        }
        set {
            _online = newValue
        }
    }
    
    var pictureURL:String {
        get {
            if _pictureURL == nil {
                return ""
            }
            return _pictureURL!
        }
        set {
            _pictureURL = newValue
        }
    }
    var phoneNumber:String {
        get {
            if _phoneNumber == nil {
                return ""
            }
            return _phoneNumber!
        }
        set {
            _phoneNumber = newValue
        }
    }
    
    override init() {
        _id = ""
        _username = ""
        _oneid = ""
    }
    init(id:String,oneid:String,username:String,email:String){
        _id = id
        _oneid = oneid
        _username = username
        _email = email
        FIRDatabase.database().reference().child("Users/\(id)").observe(.childChanged, with: {(snap) in
            let dict = snap.value as! NSDictionary
            
        })
    }
    init (id:String?="",oneid:String?="",username:String?="",email:String?="",latitude:Double?=0.0,longitude:Double?=0.0,online:Bool?=false,pictureURL:String?="",location:CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),thumbnailURL:String? = ""){
        _id = id
        _oneid = oneid
        _username = username
        _email = email
        _latitude = latitude
        _longitude = longitude
        _online = online
        _pictureURL = pictureURL
        _thumbnailURL = thumbnailURL
        FIRDatabase.database().reference().child("Users/\(id!)").observe(.childChanged, with: {(snap) in
            print("\(snap.value) LOLOLOL")
        })
    }
    required init(coder aDecoder: NSCoder) {
        _profile = (aDecoder.decodeObject(forKey: "profile") as! UIImage)
        
    }
    static func ==(left:User, right:User) -> Bool {
        return left.id == right.id
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(_profile, forKey: "profile")
    }
    func printDict(user:User) -> String{
        return "userid \(user.id) email \(user.email) latitude \(user._latitude) longitude \(user.longitude) phone \(user._phoneNumber) pictureURL: \(user.pictureURL) picture image \(user.profile) "
    }
    func toDict(user:[String:AnyObject]) -> User{
        let value = User()
        value.id = user["uid"] as! String
        value.username = user["username"] as! String
        value.oneid = user["oneid"] as! String
        value.pictureURL = user["pictureURL"] as! String
        value.phoneNumber = user["phonenumber"] as! String
        value.email = user["email"] as! String
        value.thumbnailURL = user["thumbnailURL"] as! String
        return value
    }

    
    
    func setProfileImageOffline(image:UIImage,key:String){
        let savedData = NSKeyedArchiver.archivedData(withRootObject: image)
        UserDefaults.standard.set(savedData, forKey: "\(key)")
        UserDefaults.standard.synchronize()
    }

    
    
}
