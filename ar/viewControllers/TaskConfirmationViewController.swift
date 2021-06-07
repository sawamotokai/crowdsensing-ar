//
//  TaskConfirmationViewController.swift
//  ar
//
//  Created by Kai Sawamoto on 2021-06-07.
//

import UIKit

class TaskConfirmationViewController: UIViewController {
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var dimissButotn: UIButton!
    var task: Task?

    @IBAction func accept(_ sender: Any) {
        print("Accepting")
        DispatchQueue.main.async {
            guard let vc = self.storyboard?.instantiateViewController(identifier: "ar_vc") as? ARViewController else {
                return
            }
            vc.task = self.task
            let navViewController = UINavigationController(rootViewController: vc)
            navViewController.modalPresentationStyle = .fullScreen
            self.present(navViewController, animated: true)
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
