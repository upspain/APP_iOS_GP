//
//  ViewController.swift
//  HEYPLEASE_20170403
//
//  Created by GasPay Services on 3/4/17.
//  Copyright © 2017 CamareroApp S.L. All rights reserved.
//

import UIKit
import WebKit
import Mixpanel
//import Lottie
import CoreLocation

class ViewController: UIViewController , WKScriptMessageHandler, WKNavigationDelegate, CLLocationManagerDelegate {
    
    
    //@IBOutlet weak var activity: UIActivityIndicatorView!
    //@IBOutlet weak var loader: UIActivityIndicatorView!
    //@IBOutlet var Web: UIView!
    //@IBOutlet weak var webView: UIWebView!
    private let KmyKey = "MY_KEY"
    //DECLARO LAS VARIABLES
    @IBOutlet var Web: UIView!
    //@IBOutlet var Web : UIView! = nil
    var webView: WKWebView?
    var mixpanel: Mixpanel?
    let locationManager = CLLocationManager()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    //@IBOutlet var Web: UIWebView!
    //let URL = "http://192.168.137.1:8080/mobile?app=1&version=1"
    //let URL = "http://www.google.es"
    //let URL = "http://alb-pre-app-heyplease-365777164.eu-central-1.elb.amazonaws.com"
    //let URL = "http://alb-pre-app-heyplease-365777164.eu-central-1.elb.amazonaws.com/mobile?app=1&version=1"
    let URL = "https://gourmetpay.com/mobile?app=1&version=1"
    
    
    //##var manager: OneShotLocationManager?
    
    //LOAD VIEW
    override func loadView() {
        super.loadView()
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Default.png")!)
        self.initApp();
        
    }
    //INICIALIZO LA APP
    func initApp(){
        let contentController = WKUserContentController();
        
        contentController.add(
            self,
            name: "eventMixpanel")

        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        self.webView = WKWebView(
            frame: self.Web.bounds,
            configuration: config
        )
        self.webView!.navigationDelegate=self
        //self.webView!.delegate = self
        
        self.view = self.webView!
    }
    
    
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        
        self.webView?.isUserInteractionEnabled = true
        let URLRequest = Foundation.URL(string: self.URL)
        let Request = Foundation.URLRequest(url: URLRequest!)
        //super.automaticallyAdjustsScrollViewInsets = false
        //super.navigationController?.navigationBar.isTranslucent = false
        self.webView!.load(Request)
        // add activity
        self.webView?.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        self.webView?.navigationDelegate = self
        self.activityIndicator.hidesWhenStopped = true
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        print("Starting navigating to url \(String(describing: webView.url))")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let res = navigationResponse.response as? HTTPURLResponse, res.statusCode == 404 {
            print("Not Found", "\nPlease ensure you are logged in with the correct account on GitHub\n\nIf you are using two-factor auth: There is a bug between GitHub and iOS which may cause your login to fail.  If it happens, temporarily disable two-factor auth and log in from here, then re-enable it afterwards.  You will only need to do this once.")
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        print("Finished navigating to url \(String(describing: webView.url))")
        //checklocationManagerSetting()
        checkPermissionStatus()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    /*func showAnimationLottie(){
        print("Animation Lottie")
        let animationView = LOTAnimationView(name: "LottieLogo")
        self.view.addSubview(animationView)
        animationView.play()
    }*/
    
    
     func locationManagerSetting() {
         print("****************** funcion location manager setting *******************");
         self.locationManager.requestAlwaysAuthorization()
         self.locationManager.requestWhenInUseAuthorization()
         print(CLLocationManager.locationServicesEnabled());
       
         if CLLocationManager.locationServicesEnabled() {
             print("estoy entrando al location")
             locationManager.delegate = self
             locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
             //locationManager.startUpdatingLocation()
             checkPermissionStatus()
         }
     }
     
    func showModalSetting() {
        print("****************** showModalSetting *******************");
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        print(CLLocationManager.locationServicesEnabled());
      
        if CLLocationManager.locationServicesEnabled() {
            
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                print("estoy entrando al location")
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            case .restricted:
                print(".restricted")
                //getPermissionIOS(val: "denied")
                send_permission_denied()
                locationManager.stopUpdatingLocation()
            case .denied:
                print(".denied")
                //getPermissionIOS(val: "denied")
                send_permission_denied()
                locationManager.stopUpdatingLocation()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Permiss Access")
                locationGetPermissionAccess()
            }
        }
    }

    
    
    func checkStatus() {
        print("****************** CHECK STATUS *******************");
        print(CLLocationManager.locationServicesEnabled());
        if CLLocationManager.locationServicesEnabled() {
            
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                print("voy a preguntar la proxima vez")
                print(".denied voy a enviar question")
                locationManager.stopUpdatingLocation()
                send_state_permission_native_negate(permi: "question")
            case .restricted:
                print(".restricted")
                print(".denied voy a enviar no")
                locationManager.stopUpdatingLocation()
                send_state_permission_native_negate(permi: "no")
            case .denied:
                print(".denied voy a enviar no")
                locationManager.stopUpdatingLocation()
                send_state_permission_native_negate(permi: "no")
            case .authorizedAlways, .authorizedWhenInUse:
                print("Permiss Access state")
                var currentLoc: CLLocation!
                if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                        CLLocationManager.authorizationStatus() == .authorizedAlways) {
                    currentLoc = locationManager.location
                    print("locations = \(currentLoc.coordinate.latitude) \(currentLoc.coordinate.longitude)")
                    
                    let permi = "yes"
                    
                    let dict = [
                        "permission" : permi,
                         "lat" : currentLoc.coordinate.latitude,
                         "lng" : currentLoc.coordinate.longitude
                    ] as [String : Any]
                     
                     let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: [])
                     let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                     
                     // Send the location update to the page
                     self.webView!.evaluateJavaScript("nativePermissionState(\(jsonString))") { result, error in
                         guard error == nil else {
                             print(error as Any)
                             return
                         }
                     }
                    
                }
            }
        }
    }
    
    func checkPermissionStatus() {
        print("****************** CHECKPERMISSIONSTATUS *******************");
        print(CLLocationManager.locationServicesEnabled());
    
        if CLLocationManager.locationServicesEnabled() {
            
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                print("voy a preguntar la proxima vez")
                locationManager.stopUpdatingLocation()
                UserDefaults.standard.set(".notDetermined", forKey: KmyKey)
                UserDefaults.standard.synchronize()
                send_state_permission_native_negate(permi: "question")
            case .restricted:
                print(".restricted")
                UserDefaults.standard.set(".restricted", forKey: KmyKey)
                UserDefaults.standard.synchronize()
                locationManager.stopUpdatingLocation()
                send_state_permission_native_negate(permi: "no")
            case .denied:
                print(".denied")
                UserDefaults.standard.set(".denied", forKey: KmyKey)
                UserDefaults.standard.synchronize()
                locationManager.stopUpdatingLocation()
                send_state_permission_native_negate(permi: "no")
            case .authorizedAlways:
                UserDefaults.standard.set(".authorizedAlways", forKey: KmyKey)
                UserDefaults.standard.synchronize()
                print("Permiss Access")
                locationGetPermissionAccess()
            case .authorizedWhenInUse:
                UserDefaults.standard.set(".authorizedWhenInUse", forKey: KmyKey)
                UserDefaults.standard.synchronize()
                print("Permiss Access")
                locationGetPermissionAccess()
            }
        }
    }

    func checkPermissionStatusDenied() {
        print("****************** CHECKPERMISSIONDENIED *******************");
        print(CLLocationManager.locationServicesEnabled());
    
        if CLLocationManager.locationServicesEnabled() {
            
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                print("voy a preguntar la proxima vez")
                self.locationManager.requestAlwaysAuthorization()
                self.locationManager.requestWhenInUseAuthorization()
                print(CLLocationManager.locationServicesEnabled());
              
                if CLLocationManager.locationServicesEnabled() {
                    print("estoy entrando al location")
                    locationManager.delegate = self
                    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    locationManager.startUpdatingLocation()
                }
                
                send_state_permission_native_negate(permi: "question")
            case .restricted, .denied:
                print(".denied")
                //getPermissionIOS(val: "denied")
                send_permission_denied();
                locationManager.stopUpdatingLocation()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Permiss Access")
                locationGetPermissionAccess()
            }
        }
    }
    
    func locationGetPermissionAccess() {
        locationManager.requestWhenInUseAuthorization();
        var currentLoc: CLLocation!
        
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == .authorizedAlways) {
            currentLoc = locationManager.location
            print("locations = \(currentLoc.coordinate.latitude) \(currentLoc.coordinate.longitude)")
            
            let permi = "yes"
            
            let dict = [
                "permission" : permi,
                 "lat" : currentLoc.coordinate.latitude,
                 "lng" : currentLoc.coordinate.longitude
            ] as [String : Any]
             
             let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: [])
             let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
             
             // Send the location update to the page
             self.webView!.evaluateJavaScript("nativePermissionState(\(jsonString))") { result, error in
                 guard error == nil else {
                     print(error as Any)
                     return
                 }
             }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("CHANGE No determinado")
            permissionDenegated(elem: "question")
        case .restricted, .denied:
            print("CHANGE denegado locationManager")
            permissionDenegated(elem: "denied")
             locationManager.stopUpdatingLocation()
        case .authorizedWhenInUse:
            print("CHANGE autorizado solo cuando se usa la app")
            locationGetPermissionAccess()
        case .authorizedAlways:
            print("CHANGE lo uso siempre")
            locationGetPermissionAccess()
        }
    }
    
    func send_permission_denied() {
        // Send the location update to the page
        self.webView!.evaluateJavaScript("nativeDeniedPermission()") { result, error in
            guard error == nil else {
                print(error as Any)
                return
            }
        }
    }
    
    func send_state_permission_native_negate(permi: String) {
        let dict = [
            "permission" : permi
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
        
        // Send the location update to the page
        self.webView!.evaluateJavaScript("nativePermissionState(\(jsonString))") { result, error in
            guard error == nil else {
                print(error as Any)
                return
            }
        }
    }

    func getPermissionIOS(val: String) {
        let dict = [
            "permission" : val
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
        
        // Send the location update to the page
        self.webView!.evaluateJavaScript("getPermissionIOS(\(jsonString))") { result, error in
            guard error == nil else {
                print(error as Any)
                return
            }
        }
    }
    
    func openSettings() {
        print("Voy a abrir los ajustes")
        if let bundleId = Bundle.main.bundleIdentifier,
           let url = Foundation.URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    func permissionDenegated(elem: String) {
        locationManager.stopUpdatingLocation()
        print("Location services are not enabled " + elem)
        // Send the location update to the page
        let dict = [
            "permission" : elem
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
        
        // Send the location update to the page
        self.webView!.evaluateJavaScript("nativePermissionState(\(jsonString))") { result, error in
            guard error == nil else {
                print(error as Any)
                return
            }
        }
        
        locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
   
        let dict = [
            "lat" : locValue.latitude,
            "lng" : locValue.longitude
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
        
        // Send the location update to the page
        self.webView!.evaluateJavaScript("permissionLocationNativeFromiOS(\(jsonString))") { result, error in
            guard error == nil else {
                print(error as Any)
                return
            }
        }
    }
    
    func locationManagerSettingTurnOff() {
        print("esta locationManagerSettingTurnOff")
        // Send the location update to the page
        locationManager.stopUpdatingLocation()
        send_state_permission_native_negate(permi: "no")
    }
    
    
    func userContentController(_ userContentController: WKUserContentController,didReceive message:WKScriptMessage) {
        mixpanel = Mixpanel.sharedInstance()
        /*obtengo token*/
        print("obtengo token")
        
        if let messageBody:NSDictionary = message.body as? NSDictionary {
        
            let event:String = messageBody["event"] as! String
            print("trackEventLoad -" + event)
            
            let defaults = UserDefaults.standard
            if (event == "openURL") {
                print("**************** OPEN EN NEW BROWSER ***********************")
                let user_id:String = messageBody["user_id"] as! String
                let url = NSURL(string: user_id)! as URL;
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                
            } else if (event == "permissionLocationNative") {
                print("**************** NATIVE PERMISSION ***********************")
                print(CLLocationManager.locationServicesEnabled());
                locationManagerSetting()
            } else if (event == "nativePermissionModal") {
                print("**************** NATIVE MODAL PERMISSION ***********************")
                print(CLLocationManager.locationServicesEnabled());
                showModalSetting()
            } else if (event == "permissionLocationNativeTurnOff") {
                print("**************** NATIVE PERMISSION TURN OFF ***********************")
                locationManagerSettingTurnOff()
            } else if (event == "refreshGeolocation") {
                print("*******************LOAD checkpermission******************")
                checkPermissionStatus()
            } else if(event == "permissionocationNativeTurnOff") {
                print("*******************LOAD permissionocationNativeTurnOff******************")
                locationManagerSettingTurnOff()
            } else if (event == "openSettings") {
                openSettings()
            } else if let token_device = defaults.object(forKey: "token") {
                print("existe token")
                print(token_device)
                let tok = defaults.object(forKey: "token") as! Data
                if (event == "LOGIN") {
                    let user_id:String = messageBody["user_id"] as! String
                    print("trackEventIDLoad" + user_id)
                    print("*******************LOAD*************************")
                    mixpanel?.identify(user_id)
                    mixpanel?.people.set(["$ios_app_version" : UIDevice.current.systemVersion])
                    mixpanel?.people.set(["$ios_device_model" : UIDevice.current.systemName])
                    mixpanel?.people.addPushDeviceToken(tok)
                    mixpanel?.flush()
                } else if (event == "LOGOUT" ) {
                    print("*******************RESET*************************")
                    mixpanel?.people.removePushDeviceToken(tok)
                    mixpanel?.flush()
                }
            } else {
                print("token is nil")
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}


