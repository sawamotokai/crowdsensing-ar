//
//  ARViewController.swift
//  ar
//
//  Created by Kai Sawamoto on 2021-06-04.
//

import UIKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    let config = ARImageTrackingConfiguration()
    var task: Task?
    var assignment: Assignment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AR"
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // setup AR
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
    
    
    
    @objc func dismissSelf() {
        dismiss(animated: true, completion: nil)
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
