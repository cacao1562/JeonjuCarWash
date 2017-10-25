

import UIKit

class DetailViewController : UIViewController {
    
    var param = CarVO()
    
    @IBOutlet var washname: UILabel!
    @IBOutlet var address: UILabel!
 
    @IBOutlet var tel: UIButton!
    @IBOutlet var ceoname: UILabel!
    @IBOutlet var regdate: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // self.washname.text = "(\self.param["washName"])"
        washname.text = self.param.washName
        address.text = self.param.address
        tel.setTitle(self.param.tel, for: UIControlState.normal)
        ceoname.text = self.param.ceoName
        regdate.text = self.param.regdate
        
        print (self.param)
    }
    
    @IBAction func callnumber(_ sender: Any) {   
     
        let url = NSURL(string: "tel://"+self.param.tel!)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url as URL)
        } else {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    
    
 
}
