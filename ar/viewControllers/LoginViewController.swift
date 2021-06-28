//
//  LoginViewController.swift
//  ar
//
//  Created by Kai Sawamoto on 2021-06-11.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var username: UITextField!

    @IBAction func didTapCreate(_ sender: Any) {
        // TODO: verify phone number
        // TODO: save user info on db
        saveUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.username.delegate = self
        
        if UserDefaults.standard.bool(forKey: "IS_USER_SIGNED_IN") {
            goToHome(animated: false)
            print("logged in")
            print(UserDefaults.standard.string(forKey:"USERNAME")!)
        } else {
            print("not logged in")
        }
        // Do any additional setup after loading the view.
    }
    
    private func goToHome(animated: Bool) {
        DispatchQueue.main.async {
            guard let homeVC = self.storyboard?.instantiateViewController(identifier: "home_vc") else {
                return
            }
            self.navigationController?.pushViewController(homeVC, animated: animated)
        }
    }
    
    private func saveUser() {
        let params = [
            "username": username.text
        ]
        let urlStr = "\(BASE_API_URL)/users"
        print(username.text!)
        sendRequest(urlStr: urlStr, params: params, method: "POST") {
            UserDefaults.standard.set(true, forKey: "IS_USER_SIGNED_IN")
            UserDefaults.standard.set(self.username.text, forKey: "USERNAME")
            self.goToHome(animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
}
//
//extension UIViewController {
//    func hideKeyboardWhenTappedAround() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
//    }
//
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
//}
