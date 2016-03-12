//
//  PhotoCollectionViewCell.swift
//  Swapps
//
//  Created by Altimir Antonov on 3/1/16.
//  Copyright © 2016 Altimir Antonov. All rights reserved.
//

import Foundation
import UIKit

class BMActivityIndicator: UIActivityIndicatorView {
    
    internal var offsetYAdjust: CGFloat = 0
    
    init() {
        super.init(frame: CGRectZero)
        
        hidesWhenStopped = true
        color = UIColor.grayColor()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if superview != nil {
            frame = CGRect(x: superview!.bounds.size.width/2 - 25, y: superview!.bounds.size.height/2 + offsetYAdjust - 25, width: 50, height: 50)
        } else {
            print("activity indicator superview is nil")
        }
    }
}


class PhotoCollectionViewCell: UICollectionViewCell {
    
    internal var activityIndicator: UIActivityIndicatorView?
    
    var imageView: UIImageView! {
        didSet {
            
            // check first if there is a image
            if let im = imageView.image {
                
                imageView.image = im
            }
            
            backgroundColor = .whiteColor()
            activityIndicator!.stopAnimating()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
//        imageView = UIImageView()
//        backgroundColor = UIColor(white: 0.1, alpha: 1.0)
//        imageView = UIImageView()
//        alpha = 0
//        UIView.animateWithDuration(0.5, animations: { () -> Void in
//            self.alpha = 1
//        })
//        activityIndicator = UIActivityIndicatorView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        imageView = UIImageView()
        imageView.frame = bounds
        imageView.alpha = 0
        addSubview(imageView)
        alpha = 0
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.alpha = 1
        })
        activityIndicator = UIActivityIndicatorView()
        addSubview(activityIndicator!)
        activityIndicator?.frame.size = CGSize(width: 50, height: 50)
        activityIndicator?.center = center
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.color = .whiteColor()
        activityIndicator?.startAnimating()

        
        //        imageView.frame = bounds
//        addSubview(imageView)
//        resetImage()
    }
    
    func resetImage() {
//        imageView.removeFromSuperview()
//        imageView = nil
//        imageView = UIImageView()
//        for vi in self.subviews {
//            vi.removeFromSuperview()
//        }
//        
//        imageView.frame = bounds
//        addSubview(imageView)
//        imageView.alpha = 0
//        activityIndicator = UIActivityIndicatorView()
//        activityIndicator?.frame.size = CGSize(width: 50, height: 50)
//        activityIndicator?.center = center
    }
    
    func addImage(image: UIImage) {
        
        imageView.image = image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        imageView.image = nil
//        activityIndicator?.startAnimating()
//        activityIndicator?.setNeedsLayout()
//        resetImage()
//        imageView = nil
//        imageView = UIImageView()
//        
//        resetImage()
    }
}

class PhotoCollectionViewLoadingCell: UICollectionReusableView {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        spinner.startAnimating()
        spinner.center = self.center
        addSubview(spinner)
    }
    
    func setH() {
        frame = CGRect(x: frame.origin.x,y: frame.origin.y, width: 0,height: 0)
        clipsToBounds = true
    }
}

class PhotoCollectionHeader: UICollectionReusableView {
    
    var settings: Settings?
    var add: UIButton?
    var ResTags: UILabel?
    var SentTags: UILabel?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        settings = Settings.sharedInstance()
        
        draw()
    }
    
    func draw() {
//        self.backgroundColor = .blueColor()
        
        let user = settings!.current_user
        
        let profileImage = UIImageView()
        addSubview(profileImage)
        profileImage.anchorTopCenterWithTopPadding(50, width: 80, height: 80)
        profileImage.hnk_setImageFromURL(NSURL(string:user.imageUrl)!)
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = 80/2
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.textColor = .whiteColor()
        nameLabel.textAlignment = .Center
        addSubview(nameLabel)
        
        nameLabel.alignUnder(profileImage, centeredFillingWidthWithLeftAndRightPadding: 0, topPadding: 10, height: 20)
        
//        let width = (self.width() - 4*10) / 3
        
        let specialView = UIView()
        
        addSubview(specialView)
        
        specialView.anchorBottomCenterFillingWidthWithLeftAndRightPadding(-2, bottomPadding:0, height:60)
        
        let leftBox = UIView()
        let centerBox = UIView()
        let rightBox = UIView()
        
        leftBox.layer.borderWidth = 1
        centerBox.layer.borderWidth = 1
        rightBox.layer.borderWidth = 1
        
        leftBox.layer.borderColor = UIColor.whiteColor().CGColor
        centerBox.layer.borderColor = UIColor.whiteColor().CGColor
        rightBox.layer.borderColor = UIColor.whiteColor().CGColor
        
        specialView.addSubview(leftBox)
        specialView.addSubview(centerBox)
        specialView.addSubview(rightBox)
        
//        let wi = Int(specialView.width)
        
        let boxWidth = specialView.width() / 3
        
        leftBox.frame = CGRectMake(0,0,boxWidth,specialView.height())
        centerBox.frame = CGRectMake(leftBox.xMax(),0,boxWidth,specialView.height())
        rightBox.frame = CGRectMake(centerBox.xMax(),0,boxWidth,specialView.height())
     
        add = UIButton()
        add?.setTitle("+", forState: .Normal)
        centerBox.addSubview(add!)
        add!.backgroundColor = .orangeColor()
        add!.layer.cornerRadius = 40 / 2
        add!.anchorInCenterWithWidth(40, height:40)
        add?.addTarget(self, action: "openTagView", forControlEvents: .TouchUpInside)
        
        
        let Swapp1 = UILabel()
        Swapp1.textColor = .whiteColor()
        Swapp1.textAlignment = .Center
        Swapp1.text = "Received Swapps";
        Swapp1.font = Swapp1.font.fontWithSize(14)
        leftBox.addSubview(Swapp1)
        
        Swapp1.frame = CGRectMake(0, 0, leftBox.width(), leftBox.height() / 2);
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: "swapptapped1:") // alloc] initWithTarget:self action:@selector(swapptapped:)];
        tapGesture1.numberOfTapsRequired = 1
//        settings.recSwCount = swCount;
//        settings.sentSwCount = swTags;
        ResTags = UILabel()
        ResTags!.textColor = .whiteColor()
        ResTags!.textAlignment = .Center
        ResTags!.text = (settings!.recSwCount != nil) ? settings!.recSwCount : "0"
        ResTags!.tag = 1
        ResTags!.userInteractionEnabled = true
        ResTags!.addGestureRecognizer(tapGesture1)
        
        leftBox.addSubview(ResTags!)
        
        ResTags!.frame = CGRectMake(0, Swapp1.yMax(), leftBox.width(), leftBox.height() / 2)

        let Swapp2 = UILabel()
        Swapp2.textColor = .whiteColor()
        Swapp2.textAlignment = .Center
        Swapp2.text = "Sent Swapps"
        Swapp2.font = Swapp2.font.fontWithSize(14)
        
        rightBox.addSubview(Swapp2)
        
        Swapp2.frame = CGRectMake(0, 0, rightBox.width(), rightBox.height()/2);
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "swapptapped:")
        
        tapGesture.numberOfTapsRequired = 1
        SentTags = UILabel()
        SentTags!.textColor = .whiteColor()
        SentTags!.textAlignment = .Center
        SentTags!.text = (settings!.sentSwCount != nil) ? settings!.recSwCount : "0"
        SentTags!.tag = 2
        SentTags!.userInteractionEnabled = true
        SentTags!.addGestureRecognizer(tapGesture)
        
        rightBox.addSubview(SentTags!)
        
        SentTags!.frame = CGRectMake(0, Swapp2.yMax(), rightBox.width(), rightBox.height() / 2)
        
        self.backgroundColor = .clearColor()
    }
    
    func openTagView() {
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.AddTag, object: nil)
    }
    
    func swapptapped(sender: UITapGestureRecognizer) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.RecSw, object: nil)

        
    }
    
    func swapptapped1(sender: UITapGestureRecognizer) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.SentSw, object: nil)
        
        
    }

}








