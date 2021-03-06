//
//  TagViewController.h
//  Swapp
//
//  Created by Altimir Antonov on 9/13/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import "BaseViewController.h"

@interface TagViewController : BaseViewController

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSString *imageId;
@property (nonatomic, assign) int selectedIndexPath;

@end
