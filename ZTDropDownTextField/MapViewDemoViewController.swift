//
//  MapViewDemoViewController.swift
//  ZTDropDownTextField
//
//  Created by Ziyang Tan on 8/18/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import MapKit
import AddressBookUI

class MapViewDemoViewController: UIViewController {
    
    // MARK: Instance Variables
    let geocoder = CLGeocoder()
    let region = CLCircularRegion(center: CLLocationCoordinate2DMake(37.7577, -122.4376), radius: 1000, identifier: "region")
    var placemarkList: [CLPlacemark] = []

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var fullAddressTextField: ZTDropDownTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Map View Demo"

        view.bringSubview(toFront: fullAddressTextField)
        
        fullAddressTextField.delegate = self
        fullAddressTextField.dataSourceDelegate = self
        fullAddressTextField.animationStyle = .slide
        fullAddressTextField.addTarget(self, action: #selector(MapViewDemoViewController.fullAddressTextDidChanged(_:)), for:.editingChanged)
    }
    
    // MARK: Address Helper Mehtods
    func fullAddressTextDidChanged(_ textField: UITextField) {
        if textField.text!.isEmpty {
            placemarkList.removeAll(keepingCapacity: false)
            fullAddressTextField.dropDownTableView.reloadData()
            return
        }
        
        geocoder.geocodeAddressString(textField.text!, in: region, completionHandler: { (placemarks, error) -> Void in
            if error != nil {
                print(error ?? "No Error Message")
            } else {
                self.placemarkList.removeAll(keepingCapacity: false)
                self.placemarkList = placemarks! as [CLPlacemark]
                self.fullAddressTextField.dropDownTableView.reloadData()
            }
        })
    }
    
    fileprivate func formateedFullAddress(_ placemark: CLPlacemark) -> String {
        let lines = ABCreateStringWithAddressDictionary(placemark.addressDictionary!, false)
        let addressString = lines.replacingOccurrences(of: "\n", with: ", ", options: .literal, range: nil)
        return addressString
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MapViewDemoViewController: ZTDropDownTextFieldDataSourceDelegate {
    func dropDownTextField(_ dropDownTextField: ZTDropDownTextField, numberOfRowsInSection section: Int) -> Int {
        return placemarkList.count
    }
    
    func dropDownTextField(_ dropDownTextField: ZTDropDownTextField, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        var cell = dropDownTextField.dropDownTableView.dequeueReusableCell(withIdentifier: "addressCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "addressCell")
        }
        
        cell!.textLabel!.text = formateedFullAddress(placemarkList[indexPath.row])
        cell!.textLabel?.numberOfLines = 0
        
        return cell!
    }
    
    func dropDownTextField(_ dropdownTextField: ZTDropDownTextField, didSelectRowAtIndexPath indexPath: IndexPath) {
        mapView.removeAnnotations(mapView.annotations)
        
        let placeMark = placemarkList[indexPath.row]
        
        let location = CLLocationCoordinate2D(latitude: placeMark.location!.coordinate.latitude, longitude: placeMark.location!.coordinate.longitude)
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = formateedFullAddress(placeMark)
        self.fullAddressTextField.text = annotation.title
        mapView.addAnnotation(annotation)
    }
}


extension MapViewDemoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
