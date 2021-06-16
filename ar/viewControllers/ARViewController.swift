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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AR"
        // setup AR
        self.sceneView.debugOptions = [SCNDebugOptions.showWorldOrigin, SCNDebugOptions.showFeaturePoints]
        self.sceneView.delegate = self
        guard let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "Photo", bundle: Bundle.main) else {
            print("No image available")
            return
        }
        self.config.trackingImages = trackedImages
        self.config.maximumNumberOfTrackedImages = 1
        print("Found  images")
        self.sceneView.session.run(config)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true, completion: nil)
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
                    self.dismissSelf()
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
    
    
    
    func dismissUntilRoot() {
        guard let vc = self.presentingViewController else { return }
        while (vc.presentingViewController != nil) {
            vc.dismiss(animated: true, completion: nil)
        }
    }
    
    private func completeTask() {
        let taskID = task?.id
        let rewardID = task?.rewardID
        let trashbinID = task?.trashbinID
        let params = [
            "userID": UserDefaults.standard.string(forKey:"USERNAME"),
            "taskID": taskID,
            "rewardID": rewardID,
            "trashbinID": trashbinID
        ]
        let urlStr = "\(BASE_API_URL)/tasks/complete"
        postRequest(urlStr: urlStr, params: params)
    }
}
