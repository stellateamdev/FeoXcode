//
//  MapTableViewCell.swift
//  Flag
//
//  Created by marky RE on 12/16/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import MapKit
class MapTableViewCell: UITableViewCell {
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var label:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        mapView.layer.cornerRadius = 10.0
        mapView.isZoomEnabled = false
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        mapView.isScrollEnabled = false
        mapView.layer.masksToBounds = false
        mapView.layer.shadowPath = UIBezierPath(roundedRect: mapView.layer.bounds, cornerRadius: 0).cgPath
        mapView.layer.shadowColor = UIColor.black.cgColor
        mapView.layer.shadowRadius = 3
        mapView.layer.shadowOpacity = 0.34
        mapView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        // Initialization code
    }
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    override func setNeedsLayout() {
        super.setNeedsLayout()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
