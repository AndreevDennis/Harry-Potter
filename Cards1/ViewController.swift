//
//  ViewController.swift
//  Cards
//
//  Created by Денис Андреев on 05.11.2019.
//  Copyright © 2019 Денис Андреев. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var myLabel: UILabel!
    var grifNode:SCNNode?
    var slizNode:SCNNode?
    var kogNode:SCNNode?
    var pufNode:SCNNode?
    var harryNode:SCNNode?
    var imageNodes = [SCNNode]()
    var isJumping = false
    var lbl = false
    var timer:Timer!
    var numberTimer:Timer!
   
    
    override func viewDidLoad() {
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
    
        let grifScene = SCNScene(named: "art.scnassets/ball.scn")
        let slizScene = SCNScene(named: "art.scnassets/tower.scn")
        let kogScene = SCNScene(named: "art.scnassets/third.scn")
        let pufScene = SCNScene(named: "art.scnassets/four.scn")
        let harryScene = SCNScene(named: "art.scnassets/harry.scn")
    
        
        kogNode = kogScene?.rootNode
        pufNode = pufScene?.rootNode
        grifNode = slizScene?.rootNode
        slizNode = grifScene?.rootNode
        harryNode = harryScene?.rootNode
        createTimer()
    }
    
    func createTimer(){
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector:#selector(updateTimer), userInfo: nil, repeats: true)
    }
    @objc func updateTimer(){
        if lbl == true {
            myLabel.isHidden = false
            createNumberTimer()
        } else {
            myLabel.isHidden = true
        }
    }
    func createNumberTimer(){
        numberTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector:#selector(updateTimer1), userInfo: nil, repeats: false)
    }
    
    @objc func updateTimer1(){
         myLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARImageTrackingConfiguration()
        
        if let trackingImages  = ARReferenceImage.referenceImages(inGroupNamed: "Playing Cards", bundle: Bundle.main) {
            configuration.trackingImages = trackingImages
            configuration.maximumNumberOfTrackedImages = 4
        }
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
                    
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            let size = imageAnchor.referenceImage.physicalSize
            let plane = SCNPlane(width: size.width, height: size.height)
            plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
            plane.cornerRadius = 0.005
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
            
            var shapeNode: SCNNode?
            switch imageAnchor.referenceImage.name {
            case cardType.king.rawValue:
                shapeNode = grifNode
            case cardType.queen.rawValue:
                shapeNode = slizNode
            case cardType.krest.rawValue:
                shapeNode = kogNode
            case cardType.valet.rawValue:
                shapeNode = pufNode
            case cardType.harry1.rawValue:
                shapeNode = harryNode
            case cardType.harry2.rawValue:
                shapeNode = harryNode
            default:
                break
            }
            let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 10)
            let repeatSpin = SCNAction.repeatForever(shapeSpin)
            shapeNode?.runAction(repeatSpin)
            
            guard let shape  = shapeNode else {return nil}
            
            node.addChildNode(shape)
            imageNodes.append(node)
            return node
        }
        
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if imageNodes.count == 4{
            let positionOne = SCNVector3ToGLKVector3(imageNodes[0].position)
            let positionTwo = SCNVector3ToGLKVector3(imageNodes[1].position)
            let positionThree = SCNVector3ToGLKVector3(imageNodes[2].position)
            let positionFour = SCNVector3ToGLKVector3(imageNodes[3].position)
            let distance = GLKVector3Distance(positionOne, positionTwo)
            let secondDistance = GLKVector3Distance(positionThree, positionFour)
            if distance < 0.5 && secondDistance < 0.5 {
                spinJump(node: imageNodes[0])
                spinJump(node: imageNodes[1])
                spinJump(node: imageNodes[2])
                spinJump(node: imageNodes[3])
                isJumping = true
            } else {
                isJumping = false
//
            }
        }
    }
    
    func spinJump(node:SCNNode){
        if isJumping {return}
        let shapeNode = node.childNodes[1]
        let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z:0, duration: 1)
        shapeSpin.timingMode = .easeInEaseOut
        let up = SCNAction.moveBy(x: 0, y: 0.03, z: 0, duration: 0.5)
        up.timingMode = .easeInEaseOut
        let down = up.reversed()
        let upDown = SCNAction.sequence([up,down])
        let scale = SCNAction.scale(to: 0.0, duration: 5.0)
        
        shapeNode.runAction(shapeSpin)
        shapeNode.runAction(upDown)
        shapeNode.runAction(scale)
        
        lbl = true
    }
    
   
    
    enum cardType:String {
        case king = "king"
        case queen = "queen"
        case krest = "krest"
        case valet = "valet"
        case harry1 = "harry1"
        case harry2 = "harry2"
    }
}

