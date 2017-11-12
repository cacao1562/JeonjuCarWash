

import UIKit
import GoogleMaps
import MapKit


class DetailViewController : UIViewController {
    
    var param = CarVO()
    var lat = 0.0
    var lon = 0.0
    var myaddress = ""
    
    @IBOutlet var washname: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var tel: UIButton!
    @IBOutlet var ceoname: UILabel!
    @IBOutlet var regdate: UILabel!
    @IBOutlet var star_image: UIImageView!
    
    var check = false
    
    var mark = [String]()
    var mapview : GMSMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // self.washname.text = "(\self.param["washName"])"
        washname.text = self.param.washName
        address.text = self.param.address
        tel.setTitle(self.param.tel, for: UIControlState.normal)
        ceoname.text = self.param.ceoName
        regdate.text = self.param.regdate
        
        let camera = GMSCameraPosition.camera(withLatitude: self.param.latitude!, longitude: self.param.longitude!, zoom: 16)
        self.mapview = GMSMapView.map(withFrame: CGRect(x: 0, y: self.view.frame.height/3*2, width: self.view.frame.width, height: self.view.frame.height/3), camera:camera)
        let position = CLLocationCoordinate2D(latitude: self.param.latitude!, longitude: self.param.longitude!)
        let marker = GMSMarker()
        marker.position = position
       // marker.snippet = self.param.washName
        marker.title = self.param.washName
        marker.appearAnimation = .pop
        
        marker.tracksInfoWindowChanges = true
        marker.map = self.mapview
        self.view.addSubview(self.mapview!)
        
        star_image.isUserInteractionEnabled = true //사용자로부터 발생하는 이벤트를 받을것인지
        star_image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bookMark)))
        
        let item = UserDefaults.standard.object(forKey: "item") as! [String]
        for row in item {
            if (row == self.param.washName) {
                self.star_image.image = #imageLiteral(resourceName: "star2")
            }
        }
        
    }
    
    @IBAction func applemap(_ sender: Any) {
        
        print ("위치 === \(self.lat),  \(self.lon) ")
        print (" 주소 === \(self.myaddress)")
        let regionDistance : CLLocationDistance = 1000 /*2000m = 2km이내 보기 */
        let startCoords = CLLocationCoordinate2DMake(self.lat , self.lon)
        let regionSpan = MKCoordinateRegionMakeWithDistance(startCoords, regionDistance, regionDistance)
        let targetCoords = CLLocationCoordinate2DMake(self.param.latitude!, self.param.longitude!)
        
        let startPlacemark = MKPlacemark(coordinate: startCoords, addressDictionary: nil)
        let startMapItem = MKMapItem(placemark: startPlacemark)
        startMapItem.name = self.myaddress
        
        let targetPlacemark = MKPlacemark(coordinate: targetCoords, addressDictionary: nil)
        let targetMapItem = MKMapItem(placemark: targetPlacemark)
        targetMapItem.name = self.param.washName
        
        let options: [String : Any] = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span),
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ]
        MKMapItem.openMaps(with: [startMapItem, targetMapItem], launchOptions: options)
    }
    
    
    
    @objc func bookMark(){
        if self.star_image.image == #imageLiteral(resourceName: "star1") {
        let alert = UIAlertController(title: "", message: "즐겨찾기 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in self.favorite() } )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "", message: "즐겨찾기 해제하시겠습니까?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in self.favorite() } )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true)
        }
        
    }
    
    
    func favorite() {
        if self.star_image.image == #imageLiteral(resourceName: "star1") {
        self.star_image.image = #imageLiteral(resourceName: "star2")
        //self.check = true
        var item = UserDefaults.standard.object(forKey: "item") as! [String]
            item.append(self.param.washName!)
            UserDefaults.standard.set(item, forKey: "item")
            UserDefaults.standard.synchronize()
            
        
        } else {
            self.star_image.image = #imageLiteral(resourceName: "star1")
            var item = UserDefaults.standard.object(forKey: "item") as! [String]
            let indexx = item.index(of: self.param.washName!)
            item.remove(at: indexx!)
            UserDefaults.standard.set(item, forKey: "item")
            UserDefaults.standard.synchronize()
        //    self.check = false
            
            
            
        }
        
    }
    
    @IBAction func callnumber(_ sender: Any) {
     
        let url = NSURL(string: "tel://"+self.param.tel!)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url as URL)
        } else {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_panoview" {
            
            let panoVC = segue.destination as? PanoView  
            
            panoVC?.lat = self.param.latitude
            panoVC?.lon = self.param.longitude
        }
    }
    
//    for (key,value) in UserDefaults.standard.dictionaryRepresentation() {  //userdefaults 전체 출력
//    print ("key = \(key) , value = \(value)")
//    }
//
 
}
