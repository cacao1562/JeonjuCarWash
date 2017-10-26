

import UIKit

class DetailViewController : UIViewController {
    
    var param = CarVO()
    
    @IBOutlet var washname: UILabel!
    @IBOutlet var address: UILabel!
 
    @IBOutlet var tel: UIButton!
    @IBOutlet var ceoname: UILabel!
    @IBOutlet var regdate: UILabel!
    
    @IBOutlet var star_image: UIImageView!
    
    var check = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // self.washname.text = "(\self.param["washName"])"
        washname.text = self.param.washName
        address.text = self.param.address
        tel.setTitle(self.param.tel, for: UIControlState.normal)
        ceoname.text = self.param.ceoName
        regdate.text = self.param.regdate
        
        
        star_image.isUserInteractionEnabled = true //사용자로부터 발생하는 이벤트를 받을것인지
        star_image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bookMark)))
        
    }
    
    @objc func bookMark(){
        if self.check == false {
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
        if self.check == false {
        star_image.image = #imageLiteral(resourceName: "star2")
        self.check = true
        } else {
            star_image.image = #imageLiteral(resourceName: "star1")
            self.check = false
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
    
    
    
 
}
