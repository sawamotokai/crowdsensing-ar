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
let TIME_INTERVAL: Int = 15

class ViewController: UIViewController {
    var manager: CLLocationManager?
    var lat: Double?
    var lng: Double?
    var timer: Timer?
    @IBOutlet weak var findButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findButton.layer.cornerRadius = findButton.layer.frame.height / 2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.timer?.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        createTimer()
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
    }
    
    private func createTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(TIME_INTERVAL), repeats: true, block: { [weak self] timer in
            print("sending request")
            self?.getCurrentAssignment()
        })
        self.timer?.tolerance = 100
    }
    @IBAction func onTappingFind(_ sender: Any) {
        let urlStr = "\(BASE_API_URL)/users/wait_for_task"
        let params = [
            "username" : UserDefaults.standard.string(forKey: "USERNAME")
        ]
        sendRequest(urlStr: urlStr, params: params, method: "PUT") {
            self.getCurrentAssignment()
        }
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
                        let actions: [UIAlertAction] = [
                            UIAlertAction(title: "Accept", style: .default, handler: {_ in
                                guard let vc = self.storyboard?.instantiateViewController(identifier: "routingVC") as RoutingMapViewController? else {
                                    return
                                }
                                vc.assignment = res?.assignments[0]
                                self.navigationController?.pushViewController(vc, animated: true)
                            }),
                            UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
                        ]
                        showAlert(vc: self, title: "A task was found", message: "Will you accept it?", actions: actions)
                    } else {
                        let actions: [UIAlertAction] = [UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)]
                        showAlert(vc: self, title: "Alert", message: "No tasks were found", actions: actions)
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

