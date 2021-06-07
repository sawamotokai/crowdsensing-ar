//
//  NearTasksViewController.swift
//  ar
//
//  Created by Kai Sawamoto on 2021-06-07.
//

import UIKit

class NearTasksViewController: UIViewController {
    var tasks: [Task] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nearby Tasks"
        view.backgroundColor = .systemGray3
        print("VC rendered")
        print(tasks[0])
        print(tasks[1])
        tableView.delegate = self
        tableView.dataSource = self
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

extension NearTasksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row")
        DispatchQueue.main.async {
            guard let vc = self.storyboard?.instantiateViewController(identifier: "task_confirmation_vc") as? TaskConfirmationViewController else {
                return
            }
            vc.task = self.tasks[indexPath.row]
            let navViewController = UINavigationController(rootViewController: vc)
//            navViewController.modalPresentationStyle = 
            self.present(navViewController, animated: true)
        }
    }
}

extension NearTasksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let task: Task = tasks[indexPath.row]
        cell.textLabel?.text = "(\(indexPath.row + 1)) \(task.reward.name) 📍 lat: \(task.trashbin.location.lat) lng: \(task.trashbin.location.lng)"
        return cell
    }
}
