

import UIKit
import Foundation
import GoogleMaps
import CoreLocation
import AddressBookUI


class MainViewController: UIViewController,XMLParserDelegate, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    var original_address_latitude:CLLocationDegrees = 0.0
    var original_address_longitude:CLLocationDegrees = 0.0
    var mapView:GMSMapView? = nil //구글맵 뷰 객체//
    var panoview:GMSPanoramaView? = nil
    var subview : UIView? = nil
    var subbutton : UIButton? = nil
    var subbutton2 : UIButton? = nil
    var locationManager: CLLocationManager!

    
    var page = 1
    
    lazy var list : [CarVO] = {
        var datalist = [CarVO]()
        return datalist
    }()
    var list2 : [CarVO] = []
    
    var carwash = CarVO()
    
    var kirometer : [Double] = []
    var kirometer2 : [Double] = []
    
    var elementTemp = ""
    
    var datalist : [[String:String]] = [[:]]
    var detailData : [String:String] = [:]
    var blank: Bool = false
    
    
    var washItems = [[String : String]]() // 영화 item Dictional Array
    var washItem = [String: String]()     // 영화 item Dictionary
    
    var pubTitle = "" // 영화 제목
    var contents = "" // 영화 내용
    
  
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        callCarwashApi()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        //locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        self.locationManager.pausesLocationUpdatesAutomatically = false
        
        
        //구글맵 설정//
        let camera = GMSCameraPosition.camera(withLatitude: self.original_address_latitude, longitude: self.original_address_longitude, zoom: 16)
        self.mapView = GMSMapView.map(withFrame: self.CGRectMake(0, 65, self.view.frame.width, self.view.frame.height-65), camera:camera)
        
        //이벤트 등록//
        self.mapView?.delegate = self
        //        self.locationManager.delegate = self
        //        self.locationManager.requestAlwaysAuthorization()
        
        self.mapView?.mapType = .normal  //지도의 타입 변경가능//
        self.mapView?.isIndoorEnabled = false  //실내지도 on/off설정//
        self.mapView?.isMyLocationEnabled = true   //나의 위치정보 설정(GPS상황에 따라 환경이 달라질 수 있다.). 나의 현재위치로 한번에 이동할 수 있는 버튼 등록//
        self.mapView?.settings.compassButton = true  //나침반 표시//
        self.mapView?.settings.myLocationButton = true  //나의 위치정보 알기 버튼//
        
         self.view.addSubview(self.mapView!)
        
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
            
            
            
        }
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
 
        self.locationManager.stopUpdatingLocation()
        
        for row in self.list {
            let position = CLLocationCoordinate2D(latitude: row.latitude!, longitude: row.longitude!)
            let marker = GMSMarker()
            marker.position = position
            marker.snippet = row.washName
            marker.appearAnimation = .pop
            //                    marker.title = row.washName
            marker.map = self.mapView  //nil 마커 제거
        }
        
        
        
        
        
        print("서울역-강남역 거리 :\(distance(lat1: 37.554521, lng1: 126.9684596, lat2: 37.4979462, lng2: 127.0254323))")
        // 서울역 - 강남역 거리
        
        
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.subview?.isHidden = true
    }

    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("인포 윈도우")
        self.subbutton2?.setTitle(marker.snippet!, for: UIControlState.normal)
        self.subview?.isHidden = false
        
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
            washItem = [String : String]()
            carwash = CarVO()
            pubTitle = ""
            contents = ""
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
            pubTitle = string
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
            
            // washName.text = pubTitle
            // address.text = contents
            
        }
        
        print("didEndElement : \(elementName)") // *
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_list" {
            
            let listVC = segue.destination as? TableViewController  //영화 데이터를 찾은다음, 목적지 뷰 컨트롤러의 mvo 변수에 대입
   
            for row in self.list {
                let km = distance(lat1: original_address_latitude, lng1: original_address_longitude, lat2: row.latitude!, lng2: row.longitude!)
                row.kirometer = km
                
            }

            self.list.sort(by: { (min, max) -> Bool in
                min.kirometer! < max.kirometer!
            })
            
            listVC?.carItem = self.list
       
          //  print("키로미터 : \(self.list2[0].kirometer) \n 이름 : \(self.list2[0].washName)")
            
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


