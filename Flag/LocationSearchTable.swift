//
//  LocationSearchTable.swift
//  MapKitTutorial
//
//  Created by Robert Chen on 12/28/15.
//  Copyright © 2015 Thorn Technologies. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class LocationSearchTable: UITableViewController {
    
    
    weak var handleMapSearchDelegate: HandleMapSearch?
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView?
    var searchStr = ""
    
    var searchCompleter = MKLocalSearchCompleter()
    var timer = Timer()
    let delay = 0.3
    var searchResults = [MKLocalSearchCompletion]()
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCompleter.delegate = self
        
    }
    func parseAddress(selectedItem:MKPlacemark) -> String {
        
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil &&
                            selectedItem.thoroughfare != nil) ? " " : ""
        
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) &&
                    (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil &&
                            selectedItem.administrativeArea != nil) ? " " : ""
        
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        
        return addressLine
    }
    
}
extension LocationSearchTable:MKLocalSearchCompleterDelegate {

    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchCompleter.region = (mapView?.region)!
       self.tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}
extension LocationSearchTable:UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        matchingItems.removeAll()
        
    }
   /* func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            matchingItems.removeAll()
        }
    } */
}
extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchStr = searchController.searchBar.text!
        timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(LocationSearchTable.delayAction), userInfo: nil, repeats: false)
        
    }
    func delayAction() {
        searchCompleter.queryFragment = searchStr
    }
  
      /*  guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            print("hahaha")
            self.tableView.contentOffset.y = 0
            self.tableView.reloadData()
        } */
    
    
}

extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count//matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        //let selectedItem =  matchingItems[indexPath.row].placemark
        cell.textLabel?.text = searchResults[indexPath.row].title//selectedItem.name
        cell.detailTextLabel?.text = searchResults[indexPath.row].subtitle  //parseAddress(selectedItem: selectedItem)
        return cell
    }
    
}

extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchRequest = MKLocalSearchRequest(completion: searchResults[indexPath.row])
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            let placemark = response?.mapItems[0].placemark
            self.handleMapSearchDelegate?.dropPinZoomIn(placemark: placemark!)
            self.dismiss(animated: true, completion: nil)
        }
       /*let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil) */
    }
    
}
