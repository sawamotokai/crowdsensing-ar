//
//  ViewController.swift
//  ar
//
//  Created by Kai Sawamoto on 2021-05-27.
//

import UIKit
import ARKit
import CoreLocation

let BASE_API_URL = "https://crowd-sensing.herokuapp.com/api/v0"

class ViewController: UIViewController, CLLocationManagerDelegate {
    var manager: CLLocationManager?
    var lat: Double?
    var lng: Double?
    
    @IBOutlet weak var findButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findButton.layer.cornerRadius = findButton.layer.frame.height / 2
        // location setup
//        manager  = CLLocationManager()
//        manager?.delegate = self
//        manager?.desiredAccuracy = kCLLocationAccuracyBest
//        manager?.requestWhenInUseAuthorization()
//        manager?.startUpdatingLocation()

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else {
            return
        }
        self.lat = loc.coordinate.latitude
        self.lng = loc.coordinate.longitude
    }
    
    @IBAction func onTappingFind(_ sender: Any) {
//        let url = "\(BASE_API_URL)/tasks/near?lat=\(self.lat!)&lng=\(self.lng!)"
//        getNearbyTasks(from: url)
        // TODO: just set the status to waiting. show toast message
        let msg = "Your status has been set to waiting! Wait for a task to be assigned..."
        let urlStr = "\(BASE_API_URL)/users/wait_for_task"
        let params = [
            "username" : UserDefaults.standard.string(forKey: "USERNAME")
        ]
        sendRequest(urlStr: urlStr, params: params, method: "PUT") {
            DispatchQueue.main.async {
//                self.showToast(message: msg, color: .systemGreen)
            }
        }
        getCurrentAssignment()
    }
    
    private func getCurrentAssignment() {
        guard let url = URL(string: "\(BASE_API_URL)/users/currentTasks?username=\(UserDefaults.standard.string(forKey:"USERNAME")!)") else {
            print("error in generating URL")
            return
        }
        URLSession.shared.dataTask(with: url)  { data, response, error in
            guard let data = data, error == nil else {
                print("something went wrong")
                print(error!.localizedDescription)
                return
            }
            var res: AssignmentsDTO?
            do {
                res = try JSONDecoder().decode(AssignmentsDTO.self, from: data)
            } catch {
                print("Failed to convert \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    print(httpResponse.statusCode)
                    if isSuccess(statusCode: httpResponse.statusCode) {
                        guard let vc = self.storyboard?.instantiateViewController(identifier: "routingVC") as RoutingMapViewController? else {
                            return
                        }
                        vc.assignment = res?.assignments[0]
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        // TODO: toast error message
                        let alert = UIAlertController(title: "Alert", message: "No tasks were found", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            switch action.style{
                                case .default:
                                print("default")
                                case .cancel:
                                print("cancel")
                                case .destructive:
                                print("destructive")
                            }
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }.resume()
    }
    
//    private func getNearbyTasks(from url: String) {
//        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: {data, response, error in
//            guard let data = data, error == nil else {
//                print("something went wrong")
//                print(error!.localizedDescription)
//                return
//            }
//            var result: Welcome?
//            do {
//                result = try JSONDecoder().decode(Welcome.self, from: data)
//            } catch {
//                print("Failed to convert \(error.localizedDescription)")
//            }
//            guard let json = result else {
//                print("json not found")
//                return
//            }
//
//            DispatchQueue.main.async {
//                guard let vc = self.storyboard?.instantiateViewController(identifier: "near_tasks_vc") as? NearTasksViewController else {
//                    print("VC not found")
//                    return
//                }
//                vc.tasks = json.data.tasks
//                vc.lng = self.lng
//                vc.lat = self.lat
//                let navController = UINavigationController(rootViewController: vc)
//                navController.modalPresentationStyle = .fullScreen
//                self.present(navController, animated: true)
//            }
//        }).resume()
//    }
}


extension UIViewController {

    func showToast(message : String, color: UIColor) {
        
        let toastLabel = UILabel()
        
        toastLabel.backgroundColor = color
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.frame = CGRect(origin: CGPoint(x: toastLabel.frame.origin.x, y: self.view.frame.size.height - toastLabel.frame.size.height - 5), size: toastLabel.frame.size)
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

