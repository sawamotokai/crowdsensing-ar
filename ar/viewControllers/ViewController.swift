//
//  ViewController.swift
//  ar
//
//  Created by Kai Sawamoto on 2021-05-27.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    let button = UIButton()

    @IBOutlet weak var findButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup button
        view.backgroundColor = .systemGray5
    }
    
    @IBAction func onTappingFind(_ sender: Any) {
        let tempURL = "https://ece-ar.herokuapp.com/tasks/near?lat=21&lng=21"
        getNearbyTasks(from: tempURL)
    }
    
    @objc func didTapButton() {
        guard let vc = storyboard?.instantiateViewController(identifier: "ar_vc") as? ARViewController else {
            return
        }
        let navViewController = UINavigationController(rootViewController: vc)
        navViewController.modalPresentationStyle = .fullScreen
        present(navViewController, animated: true)
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
                let navViewController = UINavigationController(rootViewController: vc)
                self.present(navViewController, animated: true)
            }
        }).resume()
    }
}


