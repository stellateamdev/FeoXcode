//
//  PageViewController.swift
//  Flag
//
//  Created by marky RE on 12/5/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import BetterSegmentedControl
import Firebase
import ZAlertView
class PageViewController: UIPageViewController{
    var currentView = 0
    var control = BetterSegmentedControl()
    @IBOutlet weak var segment: UISegmentedControl!
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController("activityFeed"),
                self.newViewController("joinActivity"),
                self.newViewController("userActivity")]
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        self.view.backgroundColor = UIColor.white
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
           self.navigationController?.navigationBar.tintColor = UIColor.stellaPurple()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
           control = BetterSegmentedControl(
            frame: CGRect(x: 0.0, y:0.0, width: segment.frame.size.width+50, height: segment.frame.size.height),
            titles: ["All", "Joined", "Created"],
            index: 0,
            backgroundColor: UIColor(red:239/255.0, green:239/255.0, blue:239/255.0, alpha:1.00),
            titleColor: UIColor(red:181/255.0, green:181/255.0, blue:181/255.0, alpha:1.00),
            indicatorViewBackgroundColor: UIColor.stellaPurple(),
            selectedTitleColor: .white)
        control.titleFont = UIFont(name: "HelveticaNeue-Bold", size: 14.0)!
        control.selectedTitleFont = UIFont(name: "HelveticaNeue-Bold", size: 14.0)!
        control.addTarget(self, action: #selector(PageViewController.segmentControl), for: .valueChanged)
        control.bouncesOnChange = false
        control.cornerRadius = 15
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(),for:.default)

        self.navigationItem.titleView = control
        self.navigationController?.navigationBar.isTranslucent = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.barTintColor = UIColor.white 
    }
    func newViewController(_ id:String) -> UIViewController {
        return (self.storyboard?.instantiateViewController(withIdentifier: id))!
    }
    func segmentControl() {
        var direction = UIPageViewControllerNavigationDirection.forward
        if Int(control.index) > currentView {
            currentView = Int(control.index)
        }
        else if Int(control.index) < currentView {
            currentView = Int(control.index)
            direction = UIPageViewControllerNavigationDirection.reverse
        }
        else {
        }
        setViewControllers([orderedViewControllers[Int(control.index)]],
                           direction: direction,
                           animated: true,
                           completion: nil)
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
extension PageViewController: UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    
    private func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
        
    }
    
    private func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        return firstViewControllerIndex
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        currentView = currentControllerIndex()
        do {
        try control.setIndex(UInt(currentView), animated: true)
        }
        catch {}
    }
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        print("after \(nextIndex)")
        return orderedViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        print("before \(previousIndex)")
        return orderedViewControllers[previousIndex]
    }
    func currentController() -> UIViewController? {
        if (self.viewControllers?.count)! > 0 {
            return self.viewControllers![0]
        }
        
        return nil
    }
    func currentControllerIndex() -> Int {
        
        let pageItemController = self.currentController()
        let viewControllerIndex = orderedViewControllers.index(of:pageItemController!)
        return viewControllerIndex!
    }
    
    @IBAction func createActivity() {
        let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                print("Connected")
              self.performSegue(withIdentifier: "createActivity", sender: self)
            } else {
                let dialog = ZAlertView(title: "Cannot create activity",
                                        message: "No internet connection, Please try again later.",
                                        closeButtonText: "Okay",
                                        closeButtonHandler: { alertView in
                                            alertView.dismissAlertView()
                }
                )
                dialog.allowTouchOutsideToDismiss = false
               /* let attrStr = NSMutableAttributedString(string: "Are you sure you want to quit?")
                attrStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSMakeRange(10, 12))
                dialog.messageAttributedString = attrStr */
                dialog.show()

                
            }
        })
        //let view = newViewController("createActivity")
        //self.navigationController?.present(view, animated: true, completion: nil)
        //self.navigationController?.pushViewController(view, animated: true)

    }
    
}
