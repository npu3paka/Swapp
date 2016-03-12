//
//  dashboard-col.swift
//  Swapps
//
//  Created by Altimir Antonov on 3/1/16.
//  Copyright © 2016 Altimir Antonov. All rights reserved.
//

import UIKit
import Alamofire
import Haneke

@objc protocol DashboardColDelegate {
    func chosenTag(info: SwappInfo, image: UIImage)
    func openTagView()
    func swappTapped(sender: Int)
}


class DashboardCollection: BaseView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var dashboardDelegate: DashboardColDelegate?
    
    // MARK: -
    // MARK: Static Declaration
    
    // MARK: -
    // MARK: Public Interface
    
    var swCount = "0"
    var swTag = "0"
    
    var photos = NSMutableOrderedSet()
    var refreshControl = UIRefreshControl()
    
    var populatingPhotos = false
    var loading = false
    var currentPage = 1
    
    var extensionUrl = ""
    var chosenLink = 1
    
    let PhotoCellIdentifier = "PhotoCell"
    let PhotoFooterViewIdentifier = "PhotoFooterView"
    let PhotoHeaderViewIdentifier = "PhotoCollectionHeader"
    
    var collectionView: UICollectionView?
    var settings: Settings?
    
    private var noImages = false
    /// ImageDownloader manager instance
    private var imageDownloader = ImageDownloader()

    // MARK: -
    // MARK: Constructor's
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: -
    // MARK: Desctructor's
    
    deinit { /* Clean up */
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: -
    // MARK: Override Base
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: -
    // MARK: Public Implementation
    override func setupUI() {
        super.setupUI()
        
        settings = Settings.sharedInstance()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificationSentLabel", name: Notifications.AddTag, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateRec", name: Notifications.RecSw, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateSent", name: Notifications.SentSw, object: nil)
        
        
        
//        setupView()
//        populatePhotos()
        
    }
    
    func updateSent() {
        print("wtf update1")
        if chosenLink != 1 && !loading {
            loading = true
            dashboardDelegate!.swappTapped(1)
        }
    }
    
    func updateRec() {
        print("wtf update2")
        if chosenLink != 2  && !loading {
            loading = true
            dashboardDelegate!.swappTapped(2)
        }
    }
    
    func updateNotificationSentLabel() {
        dashboardDelegate!.openTagView()
        //            self.sentNotificationLabel.text = "Notification sent!"
    }
    
    override func updateUI() {
        currentPage = 1
        let indexSet = NSIndexSet(indexesInRange: NSMakeRange(0,0))
        collectionView!.deleteSections(indexSet)
        
        self.photos.removeAllObjects()
        self.backgroundColor = .clearColor()
        populatePhotos()
    }
    
    override func clearUI() {
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + self.frame.size.height > scrollView.contentSize.height * 0.8 && !noImages {
            populatePhotos()
        }
    }
    
    // MARK: CollectionView
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell: PhotoCollectionViewCell?
        
        let partCell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCellIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        cell = partCell
        
        let swapp = photos.objectAtIndex(indexPath.row) as! SwappInfo

        
        
//        cell.imageView.image = nil
//        cell.resetImage()
        
        let imageURL = swapp.url
        if(swapp.canSee) {
//            imageDownloader.getImage(imageURL: swapp.url, forIndexPath: indexPath, completion: { (image) -> () in
////                if let cellToUpdate = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCollectionViewCell {
//                    cell!.imageView.image = image
////                }
//            })
            
//            let image = UIImage(named: "Lock Filled-500")
//            cell.addImage(image!)
//            
            imageDownloader.getImage(imageURL: imageURL, forIndexPath: indexPath, completion: { (image) -> () in
                if let cellToUpdate = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCollectionViewCell {
                    cellToUpdate.activityIndicator?.stopAnimating()
                    cellToUpdate.imageView.image = image!
//                    self.collectionView?.reloadItemsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)])
//                    self.collectionView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
//                    cellToUpdate.addImage(image!)
                    //                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        
                        cellToUpdate.imageView.alpha = 1
                    })
                }
            })
            
//            if let cacheObject = SKCache.get  (imageURL) as? SKCacheObject {
//                cell.activityIndicator?.stopAnimating()
//                
//                cell.addImage(UIImage(data: cacheObject.value as! NSData)!)
////                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
//                UIView.animateWithDuration(0.5, animations: { () -> Void in
//                
//                    cell.imageView.alpha = 1
//                })
//            }
//
            
//            cell.imageView.hnk_setImageFromURL(NSURL(string: imageURL)!)
            
            Alamofire.request(.GET, imageURL).response() {
                (_, _, data, _) in
                if let cellToUpdate = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCollectionViewCell {
                    cellToUpdate.activityIndicator?.stopAnimating()
                    cellToUpdate.imageView.image = UIImage(data: data!)
                    //                    self.collectionView?.reloadItemsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)])
                    //                    self.collectionView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
                    //                    cellToUpdate.addImage(image!)
                    //                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        
                        cellToUpdate.imageView.alpha = 1
                    })
                }
//                let image = UIImage(data: data!)
//                cell.addImage(image!)
//                cell.imageView.image = image
            }
        } else {
            let image = UIImage(named: "Lock Filled-500")
            cell!.activityIndicator?.stopAnimating()
            cell!.imageView.image = image!
            //                    self.collectionView?.reloadItemsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)])
            //                    self.collectionView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
            //                    cellToUpdate.addImage(image!)
            //                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
//            UIView.animateWithDuration(0.5, animations: { () -> Void in
            
                cell!.imageView.alpha = 1
//            })
//            cell!.imageView.alpha = 1
//            cell!.activityIndicator?.stopAnimating()
            
//            cell.imageView.image = image
        }
        
        return cell!
    }
    
//    func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
//        // Get the layout attributes for a standard flow layout
//        let attributes = super.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath)
//
//        attributes.footerReferenceSize =
//            return attributes
//    }
//
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: PhotoHeaderViewIdentifier, forIndexPath: indexPath) as! PhotoCollectionHeader
        
//        print(swCount)
//        print(swTag)
//        cell.SentTags!.text = swCount
//        cell.ResTags!.text = swTag
        
        return cell
    }
    
     func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let chosen = self.photos.objectAtIndex(indexPath.item) as! SwappInfo
       
        let cell : PhotoCollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath)! as! PhotoCollectionViewCell
        
        if cell.imageView.image != nil {
            dashboardDelegate!.chosenTag(chosen, image:cell.imageView.image!)
        }
//        [self presentViewController:vc animated:YES completion:nil];
        
//                performSegueWithIdentifier("ShowPhoto", sender: (self.photos.objectAtIndex(indexPath.item) as! PhotoInfo).id)
    }
    
    // MARK: Helper
    
    func updateHeader() {
        collectionView?.reloadData()
    }
    
    func setupView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1.0
        layout.minimumLineSpacing = 1.0
        
        let itemWidth = (self.bounds.size.width - 2)/3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = 1.0
        layout.minimumLineSpacing = 1.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.headerReferenceSize = CGSize(width: self.bounds.size.width, height: 250.0)
//        layout.footerReferenceSize = CGSize(width: self.bounds.size.width, height: 100.0)

        collectionView = UICollectionView(frame: CGRect(x: 0,y: 0,width: self.frame.size.width,height: self.frame.size.height), collectionViewLayout: layout)
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        self.addSubview(collectionView!)
        
        collectionView!.registerClass(PhotoCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: PhotoCellIdentifier)
        collectionView!.registerClass(PhotoCollectionHeader.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: PhotoHeaderViewIdentifier)
        collectionView!.backgroundColor = .clearColor()
        refreshControl.tintColor = .whiteColor()
        refreshControl.addTarget(self, action: "handleRefresh", forControlEvents: .ValueChanged)
        collectionView!.addSubview(refreshControl)
        
    }
    
    func handleRefresh() {
        
        
        populatePhotos()
        refreshControl.endRefreshing()
    }
    
    func populatePhotos() {
        // 2
        
        if self.noImages {
            return
        }
        
        if populatingPhotos {
            return
        }
        
        populatingPhotos = true
        
        // 3
        Alamofire.request(.POST, URLSettings.BaseURL + extensionUrl, parameters: [DashboardRequestImages.Keys.fbID: settings!.current_user.userId,"offset": (currentPage-1)*10, "limit": 10]).responseJSON() {
            response in
            // 4
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                // 5, 6, 7
                let resp = response.result.value as! NSDictionary
                
                if let message = resp["message"] as? [NSDictionary] {
                    print("message is: \(message)")
                    
                    if message.count < 10 {
                        self.noImages = true
                    }
                    //imag["s_can_see"]  isEqual: "1"] || author
                    
                    let author = self.extensionUrl.isEqual("get_author_images") ? true : false
//                    let canSee =
                    //$0["s_can_see"]!.isEqual("1") ||
                    var photoInfos = [SwappInfo]()
                    
                    for mes in message {
                         let diceRoll = Int(arc4random_uniform(100000000) + 1)
                        let tag_id = (mes["s_swapp_tag_id"] != nil) ? Int((mes["s_swapp_tag_id"] as? String)!)! : diceRoll
                        let url = "http://alti.xn----8sbarabrujldb2bdye.eu/uploads/\(mes["s_image_source"]!)"
                        var canSee = true
                        if mes["s_can_see"] != nil {
                            canSee =  (mes["s_can_see"]!.isEqual("1") || author) ? true : false
                        }
                        
                        let swappInfo = SwappInfo(id: tag_id, url: url, canSee: canSee)
                        print(tag_id)
//                        let swappInfo1 = SwappInfo(id: tag_id, url: url, canSee: canSee)
//                        let swappInfo2 = SwappInfo(id: tag_id, url: url, canSee: canSee)
//                        let swappInfo3 = SwappInfo(id: tag_id, url: url, canSee: canSee)
                        
                        print(swappInfo)
                        photoInfos.append(swappInfo)
//                        photoInfos.append(swappInfo1)
//                        photoInfos.append(swappInfo2)
//                        photoInfos.append(swappInfo3)
                        
                    }
//                    let photoInfos = message.map { SwappInfo(id: ($0["s_swapp_tag_id"] != nil) ? Int(($0["s_swapp_tag_id"] as? String)!)! : 0, url:"http://alti.xn----8sbarabrujldb2bdye.eu/uploads/\($0["s_image_source"]!)", canSee:($0["s_can_see"]) ($0["s_can_see"]!.isEqual("1") || author) ? true : false) }
//                    
                    // 8
                    let lastItem = self.photos.count
                    // 9
                    self.photos.addObjectsFromArray(photoInfos)
                    print("photos count: \(self.photos.count)")
                    // 10
                    let indexPaths = (lastItem..<self.photos.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                    
                    // 11
                    dispatch_async(dispatch_get_main_queue()) {
                        self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                    }
                    
                    self.currentPage++
                } else {
                    self.noImages = true
                    self.populatingPhotos = false
//                    let layout = UICollectionViewFlowLayout()
//                    layout.minimumInteritemSpacing = 1.0
//                    layout.minimumLineSpacing = 1.0
//                    
//                    let itemWidth = (self.bounds.size.width - 2)/2
//                    layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
//                    layout.minimumInteritemSpacing = 1.0
//                    layout.minimumLineSpacing = 1.0
//                    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                    layout.footerReferenceSize = CGSize(width: self.bounds.size.width, height: 0.0)
//                    
//                    self.collectionView!.collectionViewLayout = layout
                    return
                }
            }
            
            self.populatingPhotos = false
        }
    }
}