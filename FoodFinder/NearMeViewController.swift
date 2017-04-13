//
//  NearMeViewController.swift
//  FoodFinder
//
//  Created by Milan on 4/3/17.
//  Copyright © 2017 Milan. All rights reserved.

import UIKit
import CoreLocation
import MapKit

class NearMeViewController: UIViewController, UITableViewDataSource, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{

    @IBOutlet weak var restaurantsTable: UITableView!
    
    @IBOutlet weak var distanceTextBox: UITextField!
    @IBOutlet weak var distanceDropdown: UIPickerView!
    var distanceList = ["10", "20", "30", "40", "50"]
    
    var restaurants = [NSDictionary]()
    var userLocation:CLLocation?
    
    // create instance of .
    let locationManager = CLLocationManager()
    
    // Loads ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        restaurantsTable.dataSource = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=44.1680112%2C-93.9675153&radius=1200&type=restaurant&key=AIzaSyBaqf7fNiIr26U7nWbXz5wblqgvjg-vaiY"
        
        downloadRestaurants(urlString: url) {(array) ->() in
            self.restaurants = array as! [NSDictionary]
            self.restaurantsTable.reloadData()
            self.distanceTextBox.text = self.distanceList[0]
        }
    }
    
    // geolocation of user
    
    // Built-in function
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Returns a count of nearby restaurants
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return restaurants.count
    }
    
    // Populates data about each restaurant
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // each restaurant's lat and long
        let geometry = restaurants[indexPath.row]["geometry"] as? [String: Any]
        let location = geometry?["location"] as? [String: Any]
        let restaurantLat = location?["lat"] as? Double
        let restaurantLong = location?["lng"] as? Double
        
        cell.textLabel!.text = restaurants[indexPath.row] ["name"] as? String
        
        //cell.detailTextLabel!.text = getRestaurantDistance(lat: restaurantLat!, long: restaurantLong!)
        
        // cell.distanceLabel!.text = "distances"       create a label in prototype cell called distanceLabel
        
        return cell
    }
    
    // Populates restaurantList using the maps api and json file
    func downloadRestaurants(urlString:String,completionHandler:@escaping (_ array:NSArray)-> ()){
        var restaurantsList = [NSDictionary]()
        let url = URL(string: urlString)
        let session = URLSession.shared
        let task = session.dataTask(with:url!) { (data, response, error) -> Void in
            
            do{
                let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! NSDictionary
                let list = jsonDictionary["results"] as? [[String: AnyObject]]

                for restaurant in list! {
                    //let restaurantName = restaurant["name"] as? String
                    restaurantsList.append(restaurant as! NSDictionary)
                }
                
                DispatchQueue.main.async(execute: {
                    completionHandler(restaurantsList as NSArray)/// code goes here
                })
                
            }
            catch{
                print("invalid json format")
            }
        }
        task.resume()
    }
    
    // Assigns User's current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        userLocation = locations[0]
    }
    
    // Returns the distance between a restaurant and the User
    func getRestaurantDistance(lat:Double,long:Double) -> String{
        
        var distanceinkm:String?
        
        let restaurantLocation = CLLocation(latitude: lat, longitude: long)
        print(lat)
        print(long)
        var distance:CLLocationDistance?
        
        distance = userLocation?.distance(from: restaurantLocation)
        
        // just for test , put describing:distance later //
        distanceinkm = String(describing: lat)
        print(distance)
        return distanceinkm!
    }
    
    // Takes an array of restauraunts and returns a random restaurant name
    func getRandomRestaurant(restaurantList: Array<Any>) -> String{
        let randomName : String = {
            let randomIndex = Int(arc4random_uniform(UInt32(restaurantList.count)))
            return restaurantList[randomIndex] as! String
        }()
        return randomName
    }
    
    // This function assists the dropdown menu
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    // This function assists the dropdown menu
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return distanceList.count
    }
    
    // This function assists the dropdown menu
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        return distanceList[row]
    }
    
    // This function assists the dropdown menu
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.distanceTextBox.text = self.distanceList[row]
        self.distanceDropdown.isHidden = true
    }
    
    // This function assists the dropdown menu
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.distanceTextBox {
            self.distanceDropdown.isHidden = false
            //Disables seeing the keyboard
            textField.endEditing(true)
        }
    }
    
}
