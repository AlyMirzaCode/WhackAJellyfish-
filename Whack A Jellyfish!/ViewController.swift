//
//  ViewController.swift
//  Whack A Jellyfish!
//
//  Created by Aly Mirza on 2017-10-31.
//  Copyright © 2017 Aly Mirza. All rights reserved.
//

import UIKit
import ARKit
import Each

class ViewController: UIViewController {

    var timer = Each(1).seconds
    var countdown = 10
    @IBOutlet weak var Timer: UILabel!
    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func play(_ sender: Any) {
        self.setTimer()
        self.addNode()
        self.play.isEnabled = false
    }
    
    @IBAction func reset(_ sender: Any) {
        self.timer.stop()
        self.restoreTimer()
        self.play.isEnabled = true
        
        sceneView.scene.rootNode.enumerateChildNodes {(node, _) in
            node.removeFromParentNode()
        }
    }
    
    func addNode() {
        let jellyFishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")
        let jellyFishNode = jellyFishScene?.rootNode.childNode(withName: "JellyFish", recursively: false)
        jellyFishNode?.position = SCNVector3(randomNumbers(firstNum: -1, secondNum: 1), randomNumbers(firstNum: -0.5, secondNum: 0.5), randomNumbers(firstNum: -1, secondNum: 1))
        self.sceneView.scene.rootNode.addChildNode(jellyFishNode!)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        if hitTest.isEmpty {
            print("didnt touch anything")
        } else {
            if self.countdown > 0 {
                let results = hitTest.first!
                let geometry = results.node.geometry!
                let node = results.node
                if node.animationKeys.isEmpty {
                    SCNTransaction.begin()
                    self.animateNode(node: node)
                    SCNTransaction.completionBlock = {
                        node.removeFromParentNode()
                        self.addNode()
                        self.restoreTimer()
                    }
                    SCNTransaction.commit()
                }
            }
        }
    }
    
    func animateNode(node: SCNNode) {
        let spin = CABasicAnimation(keyPath: "position")
        spin.fromValue = node.presentation.position
        spin.toValue = SCNVector3(node.presentation.position.x - 0.2, node.presentation.position.y - 0.2,node.presentation.position.z - 0.2)
        spin.duration = 0.07
        spin.autoreverses = true
        spin.repeatCount = 5
        node.addAnimation(spin, forKey: "position")
    }
    
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random())/CGFloat(UINT32_MAX)*abs(firstNum-secondNum) + min(firstNum, secondNum)
    }
    
    func setTimer() {
        self.timer.perform { () -> NextStep in
            self.countdown -= 1
            self.Timer.text = String(self.countdown)
            if self.countdown == 0 {
                self.Timer.text = "you lose"
                return .stop
            }
            return .continue
        }
    }
    
    func restoreTimer() {
        self.countdown = 10
        self.Timer.text = String(self.countdown)
    }
}

