//
//  LocalizableViewController.swift
//  SeSACWeek9
//
//  Created by 이병현 on 2022/09/06.
//

import UIKit
import CoreLocation
import MessageUI //메일로 문의 보내기, 디바이스에서만 가능, 아이폰에 메일 계정을 등록해야 가능

class LocalizableViewController: UIViewController, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var sampleButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "navigation_title".localized
        
        myLabel.text = "introduce".localized(with: "고래밥")
        inputTextField.text = "number_text".localized(number: 11)  // %lld 안에 11이라는 매개변수가 들어가게 된다.
        
        searchBar.placeholder = "search_placeholder".localized
        inputTextField.placeholder = "textfield_placeholder".localized
        let buttonTitle = "common_cancel".localized

        sampleButton.setTitle(buttonTitle, for: .normal)
        sampleButton.addTarget(self, action: #selector(samplebuttonClicked), for: .touchUpInside)
        
        CLLocationManager().requestWhenInUseAuthorization()
    }
    
    @objc func samplebuttonClicked() {
        sendMail()
    }
    
    //문의 메일 보내기
    func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.setToRecipients(["qudgus1984@naver.com"])
            mail.setSubject("고래밥 다이어리 문의사항 -")
            mail.mailComposeDelegate = self
            
            self.present(mail, animated: true)
        } else {
            //alert. 메일 등록을 해주시거나 qudgus1984@naver.com으로 문의주세요
            print("alert")
        }
    }
    //문의 메일 처리
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            <#code#>
        case .saved:
            <#code#>
        case .sent:
            <#code#>
        case .failed:
            <#code#>
        }
        controller.dismiss(animated: true)
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with: String) -> String {
        return String(format: self.localized, with)
    }
    
    func localized(number: Int) -> String {
        return String(format: self.localized, number)
    }
}
