//
//  ActivityData.swift
//  Flag
//
//  Created by marky RE on 12/16/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import Foundation
import MapKit
import UIKit
class ActivityData {
    
    private var _location:CLLocationCoordinate2D?
    private  var _locationAddress:String?
    private  var _startdate:Date?
    private  var _startdateText:String?
    private  var _enddate:Date?
    private  var _enddateText:String?
    private  var _title:String?
    private  var _description:String?
    private  var _pictureURL:String?
    private var _type:String?
    private  var _join:[User]?
    private var _creator:String?
    private var _id:String?
    private var _key:String?
    var key:String {
        get {
            if _key == nil {
                return ""
            }
            return _key!
        }
        set {
            _key = newValue
        }
    }
    var id:String {
        get {
            if _id == nil {
                return ""
            }
            return _id!
        }
        set {
            _id = newValue
        }
    }
    var type:String {
        get {
            return _type!
        }
        set {
            _type = newValue
        }
    }
    var location:CLLocationCoordinate2D {
        get {
            return _location!
        }
        set {
            _location = newValue
        }
    }
    var locationAddress:String {
        get {
            if _locationAddress == nil {
                return ""
            }
            return _locationAddress!
        }
        set {
            _locationAddress = newValue
        }
    }
    var startdate:Date {
        get {
            return _startdate!
        }
        set {
            _startdate = newValue
        }
    }
    var startdateText:String {
        get {
            if _startdateText == nil {
                return ""
            }
            return _startdateText!
        }
        set {
            _startdateText = newValue
        }
    }
    var enddate:Date {
        get {
            return _enddate!
        }
        set {
            _enddate = newValue
        }
    }
    var enddateText:String {
        get {
            if _enddateText == nil {
                return ""
            }
            return _enddateText!
        }
        set {
            _enddateText = newValue
        }
    }
    var title:String {
        get {
            return _title!
        }
        set {
            _title = newValue
        }
    }
    var description:String {
        get {
            return _description!
        }
        set {
            _description = newValue
        }
    }

    var pictureURL:String {
        get {
            return _pictureURL!
        }
        set {
            _pictureURL = newValue
        }
    }
    var join:[User] {
        get {
            if _join == nil {
                return []
            }
            return _join!
        }
        set {
            _join = newValue
        }
    }
    var creator:String {
        get {
            return _creator!
        }
        set {
            _creator = newValue
        }
    }
    init() {
        
    }
    init(location:CLLocationCoordinate2D? = CLLocationCoordinate2D(),locationAddress:String? = "",startdate:Date? = Date(),startdateText:String? = "" ,enddate:Date? = Date(),enddateText:String? = "" ,title:String? = "",description:String? = "",pictureURL:String? = "",user:[User]? = [],type:String? = "",creator:String? = "",id:String? = "",key:String = "") {
        _location = location
        _locationAddress = locationAddress
        _startdate = startdate
        _startdateText = startdateText
        _enddate = enddate
        _enddateText = enddateText
        _title = title
        _description = description
        _pictureURL = pictureURL
        _join = user
        _type = type
        _creator = creator
        _id = id
        _key = key
    }
}
