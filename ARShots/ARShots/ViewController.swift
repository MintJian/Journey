//
//  ViewController.swift
//  ARShots
//
//  Created by Dearest on 2020/03/08.
//  Copyright © 2020 Dearest. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    
    var isLabelChanged = false
    
    var hoopAdded = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
        
        // Create a new scene
        //        let scene = SCNScene(named: "art.scnassets/hoop.scn")!
        // Set the scene to the view
        //        sceneView.scene = scene
        
//        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        screenTapped(tapGesture)
        
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        
        //use Gravity axis
        configuration.worldAlignment = .gravity
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func loadHoop(position: SCNVector3, result: ARHitTestResult) {
        let scene = SCNScene(named: "art.scnassets/hoop.scn")!
        
        sceneView.scene = scene
        loadBackboard(superPosition: position, result: result)
    }
    
    func loadBackboard(superPosition: SCNVector3, result: ARHitTestResult) {
        let node = SCNNode()
        
        let geometry = SCNBox(width: 0.6, height: 0.4, length: 0.1, chamferRadius: 0.0)
        geometry.firstMaterial?.diffuse.contents = UIColor.gray
        node.geometry = geometry
        
        let position = SCNVector3(superPosition.x + 0.0, superPosition.y + 0.0, superPosition.z + 0.0)
        node.position = position
        //        guard let currentFrame = sceneView.session.currentFrame else { return }
        //        let cameraTransform = SCNMatrix4(currentFrame.camera.transform)
        //        node.eulerAngles = SCNVector3(cameraTransform.m31, cameraTransform.m32, cameraTransform.m33)
        
        
        //        let rotate = simd_float4x4(SCNMatrix4MakeRotation(sceneView.session.currentFrame!.camera.eulerAngles.y, 0, 1, 0))
        //        let rotateTransform = simd_mul(result.worldTransform, rotate)
        
        //        guard let currentFrame = sceneView.session.currentFrame else { return }
        //
        //        let cameraTransform = SCNMatrix4(currentFrame.camera.transform)
        //        node.transform = cameraTransform
        //
        //node.eulerAngles.x -= Float.pi / 2
        //     node.eulerAngles.z -= Float.pi / 4
        node.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: node, options: [SCNPhysicsShape.Option.type :SCNPhysicsShape.ShapeType.concavePolyhedron]))
        sceneView.scene.rootNode.addChildNode(node)
        
        loadRim(superPosition: node.position, result: result)
    }
    
    func loadRim(superPosition: SCNVector3, result: ARHitTestResult) {
        let node = SCNNode()
        
        let geometry = SCNTorus(ringRadius: 0.15, pipeRadius: 0.01)
        geometry.firstMaterial?.diffuse.contents = UIColor.orange
        node.geometry = geometry
        
        let position = SCNVector3(superPosition.x + 0,superPosition.y - 0.1,superPosition.z + 0.151)
        node.position = position
        node.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: node, options: [SCNPhysicsShape.Option.type :SCNPhysicsShape.ShapeType.concavePolyhedron]))
        
        sceneView.scene.rootNode.addChildNode(node)
        
    }
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer){
        if !hoopAdded {
            let touchLocation = sender.location(in: sceneView)
            let hitTestResult = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent])
            
            if let result = hitTestResult.first {
                addHoop(result: result)
                hoopAdded = true
            }
        } else {
            createBasketball()
        }
        
    }
    
    func addHoop(result: ARHitTestResult) {
        //        let hoopScene = SCNScene(named: "art.scnassets/hoop.scn")
        
        //        guard let hoopNode = hoopScene?.rootNode.childNode(withName: "Hoop", recursively: false) else { return }
        
        let planePosition = result.worldTransform.columns.3
        let position = SCNVector3(planePosition.x, planePosition.y,planePosition.z)
        //        print(planePosition.x)
        //        print(planePosition.y)
        //        print(planePosition.z)
        
        loadHoop(position: position, result: result)
        
        //        sceneView.scene.rootNode.addChildNode(hoopNode)
    }
    
    func createFloor(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNNode()
        
        let geometry = SCNPlane(width:CGFloat(planeAnchor.extent.x),height: CGFloat(planeAnchor.extent.z))
        node.geometry = geometry
        node.eulerAngles.x = -Float.pi / 2
        node.opacity = 0.25
        
        return node
    }
    
    func createBasketball() {
        
        guard let currentFrame = sceneView.session.currentFrame else { return }
        
        let ball = SCNNode(geometry: SCNSphere(radius: 0.06))
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: ball, options: [SCNPhysicsShape.Option.collisionMargin: 0.00000001]))
        ball.physicsBody = physicsBody
        ball.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        
        let cameraTransform = SCNMatrix4(currentFrame.camera.transform)
        ball.transform = cameraTransform
        
        let power = Float(2)
        let force = SCNVector3(-cameraTransform.m31 * power, -cameraTransform.m32 * power, -cameraTransform.m33 * power)
        
        ball.physicsBody?.applyForce(force, asImpulse: true)
        
        
        sceneView.scene.rootNode.addChildNode(ball)
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        //            guard let planeAnchor = anchor as? ARPlaneAnchor else {
        //            return
        //        }
        //
        //        let floor = createFloor(planeAnchor: planeAnchor)
        //        node.addChildNode(floor)
        
        //        for node in node.childNodes {
        //            node.position = SCNVector3(planeAnchor.center.x, 0,planeAnchor.center.z)
        //            if let plane = node.geometry as? SCNPlane {
        //                plane.width = CGFloat(planeAnchor.extent.x)
        //                plane.height = CGFloat(planeAnchor.extent.z)
        //                print(plane.width)
        //                print(plane.height)
        //            }
        //
        //        }
        //        print("Found a plane")
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
