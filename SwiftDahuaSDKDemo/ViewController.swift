//
//  ViewController.swift
//  SwiftDahuaSDKDemo
//
//  Created by Shoaib Ahmed on 1/26/17.
//  Copyright © 2017 Shoaib Ahmed. All rights reserved.
//

import UIKit
import SwiftDahuaSDK

class ViewController: UIViewController {

    @IBOutlet weak var window: VideoWindow!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var nextChannelBtn: UIButton!
    @IBOutlet weak var prevChannelBtn: UIButton!
    
    
    @IBAction func onPrevChannel(_ sender: UIButton) {
        guard channel > 0 else {
            return
        }
        channel -= 1
        realPlay()
    }
    
    @IBAction func onNextChannel(_ sender: UIButton) {
        guard channel < 8 else {
            return
        }
        channel += 1
        realPlay()
    }
    
    @IBAction func onPlay(_ sender: UIButton) {
        if(sender.titleLabel?.text == "Play") {
            drp = DahuaRealplay(client: dh, channel: 3, type: DH_RType_Multiplay)
            guard (drp != nil) else {
                print("Failed to init realplay")
                onNextChannel(nextChannelBtn)
                return
            }
            
            guard drp!.play(window: window) else {
                print("Failed to play")
                return
            }
            
            sender.setTitle("Stop", for: .normal)
        }
        else {
            drp?.stop()
            drp = nil
            sender.setTitle("Play", for: .normal)
        }
        
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        sender.isEnabled = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if(sender.titleLabel?.text == "Login") {
            dp2p = DahuaP2P(serverIp: "47.88.149.226", serverPort: 8800, serverSecret: "YXQ3Mahe-5H-R1Z_")
            dh = DahuaClient()
            channel = 0
            
            let (isP2pSuccess, _localPort) = dp2p!.connect(deviceId: "1B013EFPAYKPCI7", devicePort: 37777)
            guard isP2pSuccess else {
                print("Failed to connect p2p")
                sender.isEnabled = true
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            
            localPort = _localPort
            print("> P2P connect success")
            
            let (isLoginSuccess, _, _) = dh!.login(specCap: .p2p, ip: "127.0.0.1", port: localPort!, username: "admin", password: "admin")
            guard isLoginSuccess else {
                print("Failed to login")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                sender.isEnabled = true
                return
            }
            
            print("> Device login success")
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            sender.isEnabled = true
            sender.setTitle("Logout", for: .normal)
            playBtn.isEnabled = true
        }
        else {
            sender.setTitle("Login", for: .normal)
            guard (localPort != nil) else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                sender.isEnabled = true
                return
            }
            _ = dh?.logout()
            _ = dp2p!.disconnect(localPort: localPort!)
            
            dh = nil
            dp2p = nil
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            sender.isEnabled = true
            playBtn.isEnabled = false
        }
    }
    
    
    var dp2p: DahuaP2P?
    var dh: DahuaClient?
    var drp: DahuaRealplay?
    var localPort: Int?
    
    var playPort: Int32 = 0
    var channel: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        playBtn.isEnabled = false
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // Mark: Private
    func realPlay() -> Void {
        if drp != nil {
            drp!.stop()
            drp = nil
        }
        
        drp = DahuaRealplay(client: dh, channel: channel, type: DH_RType_Realplay)
        guard (drp != nil) else {
            print("Failed to init realplay")
            return
        }
        
        guard drp!.play(window: window) else {
            print("Failed to play")
            return
        }
        
        playBtn.setTitle("Stop", for: .normal)
    }
}
