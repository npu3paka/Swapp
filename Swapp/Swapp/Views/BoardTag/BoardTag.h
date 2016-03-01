//
//  BoardTag.h
//  Swapp
//
//  Created by Altimir Antonov on 9/13/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoardTag : UIButton
@property (nonatomic, assign) BOOL full;
@property (nonatomic, assign) BOOL canSee;
@property (nonatomic, assign) CGRect fr;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, strong) NSString *swappId;
@property (nonatomic, strong) NSURL *swappUrl;



@end
