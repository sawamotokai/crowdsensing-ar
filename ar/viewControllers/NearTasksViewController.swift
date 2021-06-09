//
//  NearTasksViewController.swift
//  ar
//
//  Created by Kai Sawamoto on 2021-06-07.
//

import UIKit

class NearTasksViewController: UIViewController {
    var tasks: [Task] = []
    var lat: Double?
    var lng: Double?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nearby Tasks"
        view.backgroundColor = .systemGray3
        print("VC rendered")
        print(tasks[0])
        print(tasks[1])
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(dismissSelf))

        tasks.sort(by: {
            return coord2distMeter(current: (la: self.lat!, lo: self.lng!), target: (la: $0.trashbin.location.lat, lo: $0.trashbin.location.lng)) < coord2distMeter(current: (la: self.lat!, lo: self.lng!), target: (la: $1.trashbin.location.lat, lo: $1.trashbin.location.lng))
        })
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
    @objc func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}



extension NearTasksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            guard let vc = self.storyboard?.instantiateViewController(identifier: "task_confirmation_vc") as? TaskConfirmationViewController else {
                return
            }
            vc.task = self.tasks[indexPath.row]
            self.navigationController!.pushViewController(vc, animated: true)
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
