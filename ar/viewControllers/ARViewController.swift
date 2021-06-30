//
//  ARViewController.swift
//  ar
//
//  Created by Kai Sawamoto on 2021-06-04.
//

import UIKit
import ARKit
import CoreMotion

class ARViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    @IBOutlet weak var sceneView: ARSCNView!
    
    let config = ARImageTrackingConfiguration()
    var lat: Double?
    var lng: Double?
    var assignment: Assignment?
    var task: Task?
    var displayed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AR"
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // location setup
        if (CLLocationManager.headingAvailable()) {
            locationManager.headingFilter = 1
            locationManager.startUpdatingHeading()
            locationManager.delegate = self
            self.lat = locationManager.location?.coordinate.latitude
            self.lng = locationManager.location?.coordinate.longitude
        }
        // motion setup
        motionManager.startGyroUpdates()
        motionManager.startDeviceMotionUpdates()
        // AR setup
        self.sceneView.debugOptions = [SCNDebugOptions.showWorldOrigin, SCNDebugOptions.showFeaturePoints]
        self.sceneView.delegate = self
        guard let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "Photo", bundle: Bundle.main) else {
            print("No image available")
            return
        }
        self.config.trackingImages = trackedImages
        self.config.maximumNumberOfTrackedImages = 1
        self.sceneView.session.run(config)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGesture)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else {
            return
        }
        self.lat = loc.coordinate.latitude
        self.lng = loc.coordinate.longitude
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
        let tolarance = 5.0
        var heading = heading.magneticHeading
        heading *= -1
        heading += 90
        if heading < 0 {
            heading += 360
        }
        let dlat =  (self.assignment?.task.trashbin.location.lat)! - self.lat!
        let dlng =  (self.assignment?.task.trashbin.location.lng)! - self.lng!
        var radians = atan2(dlat, dlng)
        if (radians < 0) {
            radians += Double.pi*2.0;
        }
        let degrees = radians * 180 / Double.pi
        let dif = abs(degrees - heading)
        let margin = min(dif, 360 - dif)
        guard var elevation = motionManager.deviceMotion?.attitude.pitch else {return}
        elevation = elevation * 180 / Double.pi
        print(degrees, heading)
        let distSq = dlat * dlat + dlng * dlng
        print("dist to the item", distSq)
        if margin < tolarance && 70 <= elevation && elevation <= 90  && distSq <= 4e-6 {
            displayReward()
        }
    }
    
    func displayReward() {
        if displayed {
            return
        }
        print("rendering lego")
        let legoScene = SCNScene(named: "art.scnassets/lego.scn")!
        let legoNode = legoScene.rootNode.childNodes.first!
        guard let pov = sceneView.pointOfView else {
            return
        }
        let transform = pov.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        var currentPositionOfCamera = SCNVector3()
        currentPositionOfCamera.x = location.x + orientation.x
        currentPositionOfCamera.y = location.y + orientation.y
        currentPositionOfCamera.z = location.z + orientation.z
        legoNode.position = currentPositionOfCamera
        sceneView.scene.rootNode.addChildNode(legoNode)
        displayed = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoord = sender.location(in: sceneViewTappedOn)
        let hittest = sceneViewTappedOn.hitTest(touchCoord)
        if !hittest.isEmpty {
            print("touched something")
            completeTask()
            for obj in hittest {
                // pick up if user is at the location of the reward, otherwise error message
                obj.node.removeFromParentNode()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
                    popUntilHome(vc: self)
                }
            }
        } else {
            print("didn't touch anything")
        }
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
       let node = SCNNode()
       if let imageAnchor = anchor as? ARImageAnchor {
           let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
           plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.8)
           let planeNode = SCNNode(geometry: plane)
           planeNode.eulerAngles.x = -.pi / 2
           node.addChildNode(planeNode)
           
           let legoScene = SCNScene(named: "art.scnassets/lego.scn")!
           let legoNode = legoScene.rootNode.childNodes.first!
           legoNode.position = SCNVector3Zero
           legoNode.position.z = 0.15
           planeNode.addChildNode(legoNode)
       }
       return node
   }
    
    
    // TODO: asssingmentID
    private func completeTask() {
        let params = [
            "assignmentID": (self.assignment?.id)!
        ]
        let urlStr = "\(BASE_API_URL)/tasks/complete"
        print(params)
        print(urlStr)
        sendRequest(urlStr: urlStr, params: params, method: "PUT")
    }
}
