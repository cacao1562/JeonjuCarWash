

import UIKit
import Foundation
import GoogleMaps
import CoreLocation
import AddressBookUI


class MainViewController: UIViewController,XMLParserDelegate, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    var original_address_latitude:CLLocationDegrees = 0.0
    var original_address_longitude:CLLocationDegrees = 0.0
    var mapView:GMSMapView? = nil //구글맵 뷰 객체//
   
    var subview : UIView? = nil
    var subbutton : UIButton? = nil
    var subbutton2 : UIButton? = nil
    var locationManager: CLLocationManager = CLLocationManager()

    
    var page = 1
    
    lazy var list : [CarVO] = {
        var datalist = [CarVO]()
        return datalist
    }()
    
    var carwash : CarVO!
    
    var elementTemp = ""
    
    var address : String?
    
    var blank: Bool = false
    
    
//    var washItems = [[String : String]]() // 영화 item Dictional Array
//    var washItem = [String: String]()     // 영화 item Dictionary
//
//    var pubTitle = "" // 영화 제목
//    var contents = "" // 영화 내용
    
  
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        callCarwashApi()
        self.navigationController?.navigationBar.backgroundColor = UIColor.purple
        
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        //self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.startUpdatingLocation()
      //  self.locationManager.startUpdatingLocation()
        self.locationManager.pausesLocationUpdatesAutomatically = false
       
        //구글맵 설정//
        let camera = GMSCameraPosition.camera(withLatitude: 35.823925, longitude: 127.147863, zoom: 16)
        self.mapView = GMSMapView.map(withFrame: self.CGRectMake(0, 0, self.view.frame.width, self.view.frame.height), camera:camera)
        
        //이벤트 등록//
        
        self.mapView?.delegate = self
        self.locationManager.delegate = self
        //  self.locationManager.requestAlwaysAuthorization()
        
        self.mapView?.mapType = .normal  //지도의 타입 변경가능//
        self.mapView?.isIndoorEnabled = false  //실내지도 on/off설정//
        self.mapView?.isMyLocationEnabled = true   //나의 위치정보 설정(GPS상황에 따라 환경이 달라질 수 있다.). 나의 현재위치로 한번에 이동할 수 있는 버튼 등록//
        self.mapView?.settings.compassButton = true  //나침반 표시//
        self.mapView?.settings.myLocationButton = true  //나의 위치정보 알기 버튼//
        
        self.view.addSubview(self.mapView!)
        
        for row in self.list {
            let km = distance(lat1: self.original_address_latitude, lng1: self.original_address_longitude, lat2: row.latitude!, lng2: row.longitude!)
            row.kirometer = km
        }
        
        //현재위치로부터 거리값이 작은순으로 정렬
        self.list.sort(by: { (min, max) -> Bool in
            min.kirometer! < max.kirometer!
        })
        

        let plist = UserDefaults.standard
        let item = [String]()
        plist.set(item, forKey: "item")
        plist.synchronize()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coor = manager.location?.coordinate {
            //latitude:위도, longitude:경도
            
            //                locations = CLLocation(latitude: coor.latitude, longitude: coor.longitude)
            //
            //                convertToAddressWith(coordinate: location!)
            
            self.original_address_latitude = coor.latitude
            self.original_address_longitude = coor.longitude
            
            print ("latitude: \(coor.latitude)")
            print ("longitude: \(coor.longitude)")
            
         let camera = GMSCameraPosition.camera(withLatitude: coor.latitude, longitude: coor.longitude, zoom: 16)
     //       self.mapView?.animate(toViewingAngle: 45)
           self.mapView?.animate(to: camera)
            
            let location = CLLocation(latitude: coor.latitude, longitude: coor.longitude)
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(location) { (placemarks, error) -> Void in
                if error != nil {
                    NSLog("\(error)")
                    return
                }
                guard let placemark = placemarks?.first,
                    let addrList = placemark.addressDictionary?["FormattedAddressLines"] as? [String] else {
                        return
                }
                let address = addrList.joined(separator: " ")
//                let obj = DetailViewController()
//                obj.lat = coor.latitude
//                obj.lon = coor.longitude
//                obj.which = address
                self.address = address
                print("현재주소 ==== \(address)")
            }
            
            self.locationManager.stopUpdatingLocation()
        }
    }
    
 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        print("viewWillAppear")
        print("lat =  \(self.original_address_latitude)")
        print("lon = \(self.original_address_longitude)")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
 
     
        
        
      //  self.view = self.mapView!
        
        self.subview = UIView()
        self.subbutton = UIButton(type: UIButtonType.system)
        self.subbutton2 = UIButton(type: UIButtonType.system)
        
        self.subview?.frame = CGRect(x: 0, y: self.view.frame.height/2+110, width: self.view.frame.width, height: self.view.frame.size.height/2-110)
        self.subview?.backgroundColor = UIColor.white
        self.subview?.layer.cornerRadius = 10
        
        self.subbutton?.frame = CGRect(x: 0, y: (self.subview?.frame.size.height)!/3*2, width: self.view.frame.width/2, height: (self.subview?.frame.size.height)!/3 )
        self.subbutton?.setTitle("자세히 보기", for: UIControlState.normal)
        self.subbutton?.backgroundColor = UIColor.gray
        self.subbutton?.layer.cornerRadius = 10
        
        self.subbutton2?.frame = CGRect(x: self.view.frame.width/2, y: (self.subview?.frame.size.height)!/3*2, width: self.view.frame.width/2, height: (self.subview?.frame.size.height)!/3 )
        self.subbutton2?.setTitle("닫 기", for: UIControlState.normal)
        self.subbutton2?.backgroundColor = UIColor.gray
        self.subbutton2?.layer.cornerRadius = 10
        
        
        self.subview?.addSubview(self.subbutton!)
        self.subview?.addSubview(self.subbutton2!)
        
        
        self.view.addSubview(self.subview!)
        
        
        self.subview?.isHidden = true
        for row in self.list {
            let position = CLLocationCoordinate2D(latitude: row.latitude!, longitude: row.longitude!)
            let marker = GMSMarker()
            marker.position = position
            marker.snippet = row.washName
            marker.appearAnimation = .pop
            
            //                    marker.title = row.washName
            marker.map = self.mapView  //nil 마커 제거

            }

        
        print("viewDidAppear")
        print("lat =  \(self.original_address_latitude)")
        print("lon = \(self.original_address_longitude)")
        print("서울역-강남역 거리 :\(distance(lat1: 37.554521, lng1: 126.9684596, lat2: 37.4979462, lng2: 127.0254323))")
        // 서울역 - 강남역 거리
        
        
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.subview?.isHidden = true
    }

    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("인포 윈도우")
        for row in self.list {
            if (row.washName! == marker.snippet!) {
                print("row washName = \(row.washName!)")
                
                
                guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: "DetailView") as? DetailViewController else {
                    return
                }
                uvc.param = row
                uvc.lat = self.original_address_latitude
                uvc.lon = self.original_address_longitude
                uvc.myaddress = self.address!
                
                self.navigationController?.pushViewController(uvc, animated: true)
                }
        //let movieinfo = self.list[path!.row]  //api 영화 데이터배열 중에서 선택된 행에 대한 데이터 추출
       // NSLog("///Log data value /// \n \(movieinfo)")

       // self.navigationController?.pushViewController(DetailViewController, animated: true)
//        self.subbutton2?.setTitle(marker.snippet!, for: UIControlState.normal)
//        self.subview?.isHidden = false
        
            }
    }
    
    func callCarwashApi() {
        let baseURL = "http://openapi.jeonju.go.kr/rest/carwashservice/getCarWash?ServiceKey=y5HKUUPNVoPnZ%2BPqXjIFKYWQL%2BhY5v%2B0e0LE6DJV29kwS1XBS5ZR00ueXE%2BXNQM1O48PswM3e%2FOla81akkXFKw%3D%3D&pageNo=\(self.page)&numOfRows=286" // xml 파일이 있는 url 주소입니다.
        
        let xmlParser = XMLParser(contentsOf: URL(string: baseURL)!)
        
        xmlParser!.delegate = self
        
        xmlParser!.parse()
        
    }
    
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                
                namespaceURI: String?, qualifiedName qName: String?,
                
                attributes attributeDict: [String:String] = [:]) {
        
        print("didStartElement : \(elementName)") // *
        
        elementTemp = elementName
        // 공백에 대한 처리
        
        blank = true
        
        if (elementName == "list") {
           // washItem = [String : String]()
            carwash = CarVO()
          //  pubTitle = ""
           // contents = ""
        }
        
        
        
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        print("foundCharacters : \(string)") // *
        
        /*  if blank == true && elementTemp != "data" && elementTemp != "school" {
         
         detailData[elementTemp] = string
         } */
        
        
        
        if (elementTemp == "apiNewAddress") {
            carwash.address = string
        } else if (elementTemp == "apiName") {
            carwash.washName = string
        } else if (elementTemp == "apiTel") {
            carwash.tel = string
        } else if (elementTemp == "apiRegDate") {
            carwash.regdate = string
        } else if (elementTemp == "apiCeoName") {
            carwash.ceoName = string
        } else if (elementTemp == "apiLat") {
            carwash.latitude = ((string as NSString).doubleValue)
        } else if (elementTemp == "apiLng") {
            carwash.longitude = ((string as NSString).doubleValue)
        }
        
        
        
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        
        if (elementName == "list") {
            
            self.list.append(carwash)
            
        }
        
        print("didEndElement : \(elementName)") // *
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_list" {
            
            let listVC = segue.destination as? TableViewController
   
            
            
            listVC?.carItem = self.list
            listVC?.lat = self.original_address_latitude
            listVC?.lon = self.original_address_longitude
            listVC?.myaddress = self.address
          
            
        } else if segue.identifier == "segue_book" {
            let bookVC = segue.destination as? BookMarkViewController
            bookVC?.carItem = self.list
            bookVC?.lat = self.original_address_latitude
            bookVC?.lon = self.original_address_longitude
            bookVC?.address = self.address
        }
        
        
        
     
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    
    // 구 삼각법을 기준으로 대원거리(m단위) 요청
    func distance(lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double {
        
        // 위도,경도를 라디안으로 변환
        let rlat1 = lat1 * M_PI / 180
        let rlng1 = lng1 * M_PI / 180
        let rlat2 = lat2 * M_PI / 180
        let rlng2 = lng2 * M_PI / 180
        
        // 2점의 중심각(라디안) 요청
        let a =
            sin(rlat1) * sin(rlat2) +
                cos(rlat1) * cos(rlat2) *
                cos(rlng1 - rlng2)
        let rr = acos(a)
        
        // 지구 적도 반경(m단위)
        let earth_radius = 6371.0  //km
//        let earth_radius = 6378140.0 m
        // 두 점 사이의 거리 (m단위)
        let distance = earth_radius * rr
        
        return distance
        
       
    }
    
    

    
}


