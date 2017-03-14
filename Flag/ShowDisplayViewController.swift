//
//  ShowDisplayViewController.swift
//  Flag
//
//  Created by marky RE on 12/3/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit

class ShowDisplayViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var close:UIButton!
    var image = UIImage.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        print("fuck this shit please \(self.imageView)")
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(ShowDisplayViewController.panClose)))
        self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShowDisplayViewController.closeView)))
        self.view.backgroundColor = UIColor.black
        
        self.tabBarController?.tabBar.isHidden = true
        
        let dismiss = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        dismiss.tintColor = UIColor.white
        dismiss.setImage(UIImage(named:"Delete"), for: .normal)
        dismiss.addTarget(self, action: #selector(ShowDisplayViewController.closeView), for: .touchUpInside)
        imageView.addSubview(dismiss)
        self.imageView.bringSubview(toFront: dismiss)
        imageView.backgroundColor = UIColor.clear
        
        imageView.isUserInteractionEnabled = true
        imageView.image = image
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func closeTap() {
        print("taptap")
        closeView()
    }
    func closeView() {
        print("wtf is it enter?")
        UIView.animate(withDuration: 0.3, animations: { _ in
            print("maxY")
            self.view.frame = CGRect(x: 0,y:self.view.frame.maxY, width: self.view.frame.size.width, height: self.view.frame.size.height)
        },completion: { _ in
            print("ans \(self.view.frame)")
            self.tabBarController?.tabBar.isHidden = false
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "closeImageView")))})

        
    }
    func panClose(gesture:UIPanGestureRecognizer) {
        let y = self.view.frame.minY
        let translation = gesture.translation(in: self.view)
        print("check translation \(y) \(translation.y)")
        if gesture.velocity(in: self.view).y >= 0 && translation.y >= 0 {
        self.view.frame = CGRect(x: 0, y:y+translation.y, width: self.view.frame.size.width, height: self.view.frame.size.height)

          if gesture.state == .ended || (self.view.frame.minY >= (self.view.frame.size.height - (3.8*self.view.frame.size.height/4.0))){
            print(".ended")
            if self.view.frame.minY >= (self.view.frame.size.height - (3.8*self.view.frame.size.height/4.0)) {
                print("pass if")
                UIView.animate(withDuration: 1.5, animations: { _ in
                    print("maxY")
                    self.view.frame = CGRect(x: 0,y:self.view.frame.maxY, width: self.view.frame.size.width, height: self.view.frame.size.height)
                },completion: { _ in
                    print("ans \(self.view.frame)")
                    self.tabBarController?.tabBar.isHidden = false
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "closeImageView")))})
            }
            else {
                print("pass else")
                UIView.animate(withDuration: 0.3, animations: {_ in
                    self.view.frame = CGRect(x: 0,y:-32, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
          }
        }
         gesture.setTranslation(CGPoint.zero, in: self.view)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
}
