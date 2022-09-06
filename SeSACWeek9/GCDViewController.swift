//
//  GCDViewController.swift
//  SeSACWeek9
//
//  Created by 이병현 on 2022/09/02.
//

import UIKit

class GCDViewController: UIViewController {
    let url1 = URL(string: "https://apod.nasa.gov/apod/image/2201/OrionStarFree3_Harbison_5000.jpg")!
    let url2 = URL(string: "https://apod.nasa.gov/apod/image/2112/M3Leonard_Bartlett_3843.jpg")!
    let url3 = URL(string: "https://apod.nasa.gov/apod/image/2112/LeonardMeteor_Poole_2250.jpg")!
    
    @IBOutlet weak var imageFirst: UIImageView!
    @IBOutlet weak var imageSecond: UIImageView!
    @IBOutlet weak var imageThird: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func serialSync(_ sender: UIButton) {
        
        print("START", terminator: " ")
        
        for i in 1...100 {
            print(i, terminator: " ")
        }
        
        for i in 101...200 {
            print(i, terminator: " ")
        }
        
        //        DispatchQueue.main.sync {
        //            // 왜 문제가 생기는지
        //            for i in 101...200 {
        //                print(i, terminator: " ")
        //            }
        //        }
        
        print("END")
    }
    
    @IBAction func serialAsync(_ sender: UIButton) { // UI
        
        print("START", terminator: " ")
        
        //        DispatchQueue.main.async {
        //            for i in 1...100 {
        //                print(i, terminator: " ")
        //            }
        //        }
        
        for i in 1...100 {
            DispatchQueue.main.async {
                print(i, terminator: " ")
            }
        }
        
        for i in 101...200 {
            print(i, terminator: " ")
        }
        
        print("END")
        
    }
    
    @IBAction func globalSync(_ sender: UIButton) {
        print("START", terminator: " ")
        
        DispatchQueue.global().sync { // 결국 main 쓰레드에서 작업하는 것과 유사하게 동작하기 때문에 실질적으로 main 쓰레드에서 동작함
            for i in 1...100 {
                print(i, terminator: " ")
            }
        }
        
        
        for i in 101...200 {
            print(i, terminator: " ")
        }
        
        print("END")
    }
    
    @IBAction func globalAsync(_ sender: UIButton) { // 통신
        print("START \(Thread.isMainThread)", terminator: " ")
        
        //        DispatchQueue.global().async {
        //            for i in 1...100 {
        //                print(i, terminator: " ")
        //            }
        //        }
        
        for i in 1...100 {
            DispatchQueue.global().async {
                print(i, terminator: " ")
            }
        }
        
        for i in 101...200 {
            print(i, terminator: " ")
        }
        
        print("END \(Thread.isMainThread)")
    }
    
    @IBAction func qos(_ sender: UIButton) {
        
        let customQueue = DispatchQueue(label: "concurrentSeSAC", qos: .userInteractive, attributes: .concurrent)
        
        customQueue.async {
            print("START")
        }
        
        //가장 후순위의 작업
        for i in 1...100 {
            DispatchQueue.global(qos: .background).async {
                print(i, terminator: " ")
            }
        }
        
        
        //가장 중요도가 높은 작업 : 먼저 실행
        for i in 101...200 {
            DispatchQueue.global(qos: .userInteractive).async {
                print(i, terminator: " ")
            }
        }
        
        
        
        for i in 201...300 {
            DispatchQueue.global(qos: .utility).async {
                print(i, terminator: " ")
            }
        }
        
    }
    
    
    @IBAction func dispatchGroup(_ sender: UIButton) {
        //비동기 처리로 보내고, 작업을 다 받은다음 다음 코드를 실행하고 싶을 때
        let group = DispatchGroup()
        
        DispatchQueue.global().async(group: group) {
            for i in 1...100 {
                print(i, terminator: " ")
            }
        }
        
        DispatchQueue.global().async(group: group) {
            for i in 101...200 {
                print(i, terminator: " ")
            }
        }
        
        DispatchQueue.global().async(group: group) {
            for i in 201...300 {
                print(i, terminator: " ")
            }
        }
        
        group.notify(queue: .main) {
            print("끝") //tableView.reload
        }
        
    }
    
    func request(url: URL, completionHandler: @escaping (UIImage?) -> Void) {
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completionHandler(UIImage(systemName: "star"))
                return
            }
            
            let image = UIImage(data: data)
            completionHandler(image)
            
        }.resume()
    }
    
    @IBAction func dispatchGroupNASA(_ sender: UIButton) {
//        request(url: url1) { image in
//            print("1")
//            self.request(url: self.url2) { image in
//                print("2")
//                self.request(url: self.url3) { image in
//                    print("3")
//                    print("끝. 갱신.")
//                }
//            }
//        }
        let group = DispatchGroup()
        
        DispatchQueue.global().async(group: group) {
            self.request(url: self.url1) { image in
                print("1")
            }
        }
        
        DispatchQueue.global().async(group: group) {
            self.request(url: self.url2) { image in
                print("2")
            }
        }
        
        DispatchQueue.global().async(group: group) {
            self.request(url: self.url3) { image in
                print("3")
            }
        }
        
        group.notify(queue: .main) {
            print("끝. 완료")
        }

        
    }
    
    @IBAction func enterLeave(_ sender: UIButton) {
        
        let group = DispatchGroup()
        
        var imageList: [UIImage] = []
        
        group.enter() // RC + 1
        request(url: url1) { image in
            imageList.append(image!)
            group.leave() // RC - 1
        }
        group.enter()
        request(url: url2) { image in
            imageList.append(image!)
            group.leave()
        }
        group.enter()
        request(url: url3) { image in
            imageList.append(image!)
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.imageFirst.image = imageList[0]
            self.imageSecond.image = imageList[1]
            self.imageThird.image = imageList[2]
        }
    }
    
    @IBAction func raceCondition(_ sender: UIButton) {
        
        let group = DispatchGroup()
        
        var nickname = "SeSAC"
        
        DispatchQueue.global(qos: .userInteractive).async(group: group) {
            nickname = "고래밥"
            print("first: \(nickname)")
        }
        
        DispatchQueue.global(qos: .userInteractive).async(group: group) {
            nickname = "칙촉"
            print("second: \(nickname)")
        }
        
        DispatchQueue.global(qos: .userInteractive).async(group: group) {
            nickname = "올라프"
            print("third: \(nickname)")
        }
        
        group.notify(queue: .main) {
            print("result: \(nickname)") // ???
        }
    }
}
