

import UIKit



class BookMarkViewController : UITableViewController {
    
    
    var lat : Double?
    var lon : Double?
    var address : String?
    
    var carItem : [CarVO] = []
    var item = UserDefaults.standard.object(forKey: "item") as? [String] ?? ["즐겨찾기가 없습니다"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.item.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     

        let row = self.item[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell") as! BookMarkCell
        cell.washName.text = row
    
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       
        
        for row in self.carItem {
            if (row.washName == self.item[indexPath.row]) {
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: "DetailView") as? DetailViewController else {
            return
        }
        uvc.param = row
        uvc.lat = self.lat!
        uvc.lon = self.lon!
        uvc.myaddress = self.address!
        
        self.navigationController?.pushViewController(uvc, animated: true)
            }
        }
    }
    
}
