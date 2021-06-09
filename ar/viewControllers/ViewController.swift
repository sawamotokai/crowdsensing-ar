//
//  ViewController.swift
//  ar
//
//  Created by Kai Sawamoto on 2021-05-27.
//

import UIKit
import ARKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate {
    let button = UIButton()
    var manager: CLLocationManager?
    var lat: Double?
    var lng: Double?
    
    @IBOutlet weak var findButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray5
        
        // location setup
        manager  = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        manager?.requestWhenInUseAuthorization()
        manager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else {
            return
        }
        self.lat = loc.coordinate.latitude
        self.lng = loc.coordinate.longitude
    }
    
    @IBAction func onTappingFind(_ sender: Any) {
        let tempURL = "https://ece-ar.herokuapp.com/tasks/near?lat=\(self.lat!)&lng=\(self.lng!)"
        getNearbyTasks(from: tempURL)
    }
    
    
    private func getNearbyTasks(from url: String) {
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: {data, response, error in
            guard let data = data, error == nil else {
                print("something went wrong")
                print(error!.localizedDescription)
                return
            }
            var result: Welcome?
            do {
                result = try JSONDecoder().decode(Welcome.self, from: data)
            } catch {
                print("Failed to convert \(error.localizedDescription)")
            }
            guard let json = result else {
                print("json not found")
                return
            }
            
            DispatchQueue.main.async {
                guard let vc = self.storyboard?.instantiateViewController(identifier: "near_tasks_vc") as? NearTasksViewController else {
                    print("VC not found")
                    return
                }
                vc.tasks = json.data.tasks
                vc.lng = self.lng
                vc.lat = self.lat
                let navController = UINavigationController(rootViewController: vc)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true)
            }
        }).resume()
    }
}


