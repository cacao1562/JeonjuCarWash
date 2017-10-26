

import UIKit

class TableViewController : UITableViewController {
    
    var obj = MainViewController()
    var carItem : [CarVO] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.carItem = obj.list
        self.tableView.reloadData()
    }
    
    @IBAction func moreBtn(_ sender: Any) {
        
        obj.page += 1
        obj.callCarwashApi()
        self.carItem.removeAll()
        self.carItem = obj.list
        self.tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.carItem.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.carItem[indexPath.row]
//        let row = obj.list[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! CarCell
        
        cell.title.text = row.washName
        cell.address.text = row.address
        let km = row.kirometer?.roundToPlaces(places: 2)
        cell.kilometer?.text = "\(km!) km"
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        if (segue.identifier=="segue_detail") {
//
//            //선택된 셀의 행 정보
//            let path = self.tableView.indexPath(for: sender as! UITableViewCell)
//
//            //선택된 셀에 사용된 데이터
//            let data = self.carItem[path!.row]
//            NSLog("///Log data value /// \n \(data)")
//
////            let detailVC = segue.destination as? DetailViewController
////            detailVC?.param = [data]
//            //세그웨이가 이동할 목적지 뷰 컨트롤러 객체를 구하고, 선언된 param 변수에 데이터를 연결
//            (segue.destination as? DetailViewController)?.param = [data]
//
//        }
        
        if segue.identifier == "segue_detail" { //실행된 세그웨이의 식별자가 ""이라면
            
            let cell = sender as! CarCell   //sender인자를 캐스팅하여 테이블 셀 객체로 변환
            
            let path = self.tableView.indexPath(for: cell)  //첫번째 인자값을 이용해 몇번째 행을 선택했는지 확인
            
            let movieinfo = self.carItem[path!.row]  //api 영화 데이터배열 중에서 선택된 행에 대한 데이터 추출
            NSLog("///Log data value /// \n \(movieinfo)")
            
            let detailVC = segue.destination as? DetailViewController  
            
            detailVC?.param = movieinfo
        }
    
    
    
    }
    
 

}

extension Double {
    /// Rounds the double to decimal places value
    mutating func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }
}
