//
//  PopVC.swift
//  pixel-city
//
//  Created by Jeff Umandap on 3/29/21.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImgView: UIImageView!
    @IBOutlet weak var popImgInfoView: UIView!
    
    @IBOutlet weak var popImgTitle: UILabel!
    @IBOutlet weak var popImgDesc: UILabel!
    @IBOutlet weak var popImgPostedBy: UILabel!
    @IBOutlet weak var popImgDate: UILabel!
    
    var passedImage : UIImage!
    var passedTitle : String!
    var passedDesc : String!
    var passedPostBy : String!
    var passedPostDate : String!
    
    
    func initData(forImage image: UIImage, forTitle title: String, forDesc desc: String, forPostBy postBy: String, forPostDate date: String) {
        self.passedImage = image
        self.passedTitle = title
        self.passedDesc = desc
        self.passedPostBy = postBy
        self.passedPostDate = date
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popImgView.image = passedImage
        popImgTitle.text = passedTitle
        popImgDesc.text = passedDesc
        popImgPostedBy.text = passedPostBy
        popImgDate.text = passedPostDate
        
        
        popImgInfoView.layer.cornerRadius = 7.5
        popImgInfoView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0.5036386986)
        
//        rgb(99, 110, 114)
        
        addDoubleTap()
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped))
        
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func screenWasDoubleTapped() {
        dismiss(animated: true, completion: nil)
    }
}
