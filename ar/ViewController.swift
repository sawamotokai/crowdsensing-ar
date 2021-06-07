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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup button
        view.backgroundColor = .systemPink
        button.setTitle("AR Experience", for: .normal)
        view.addSubview(button)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.frame = CGRect(x: 100, y: 100, width: 200, height: 50)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        print("before")
        getTasks(from: "https://ece-ar.herokuapp.com/tasks/near?lat=21&lng=21")
        print("After")
    }
    
    
    @objc func didTapButton() {
//        let rootViewController = ARViewController()
        guard let vc = storyboard?.instantiateViewController(identifier: "ar_vc") as? ARViewController else {
            return
        }
        let navViewController = UINavigationController(rootViewController: vc)
        navViewController.modalPresentationStyle = .fullScreen
        present(navViewController, animated: true)
        
    }
    
}


