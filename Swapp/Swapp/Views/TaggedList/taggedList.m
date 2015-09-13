//
//  taggedList.m
//  Swapp
//
//  Created by Altimir Antonov on 7/28/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import "taggedList.h"
#import "User.h"
#import "UIView+Ext.h"
#import "UIKit+AFNetworking.h"
#import "tagsRow.h"
#import "delButton.h"

@implementation taggedList {
    NSArray *tags;
    UIScrollView *_scrollView;

}

-(instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.shown = NO;
    
    return self;
}

- (void) addTags: (NSArray *)fr {
    tags = fr;

    for(UIView *v in [_scrollView subviews]) {
        [v removeFromSuperview];
    }
    
    CGFloat size = 50;

    UIView *simpleView = [UIView new];
    [_scrollView addSubview:simpleView];
    //    [simpleView anchorTopCenterFillingWidthWithLeftAndRightPadding:0 topPadding:0 height:];
    
    [simpleView anchorTopLeftWithLeftPadding:0 topPadding:0 width:self.frame.size.width height:tags.count*(size)];
    
    NSMutableArray *views = [[NSMutableArray alloc]init];
    
    for (tagView *tag in tags) {
        
        User *user = tag.user;
        UIView *lastVi;
        lastVi = [views lastObject];
//        UITapGestureRecognizer *singleFingerTap =
//        [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                action:@selector(handleSingleTap:)];
//        
        tagsRow *userVi = [[tagsRow alloc]init];
        
        [simpleView addSubview:userVi];
        //[userVi addGestureRecognizer:singleFingerTap];
        
        userVi.user = user;
        if(lastVi != nil) {
            //            [userVi alignUnder:lastVi matchingCenterWithTopPadding:padding width:200 height:size];
            
            [userVi alignUnder:lastVi matchingLeftWithTopPadding:0 width:simpleView.frame.size.width height:size];
            
        } else {
            
            //[userVi anchorTopCenterFillingWidthWithLeftAndRightPadding:0 topPadding:0 height:size];
            
            [userVi anchorTopLeftWithLeftPadding:0 topPadding:0 width:simpleView.frame.size.width height:size];
            //anchorTopCenterWithTopPadding:7 width:200 height:45];
        }
        
        
        
        
        CGFloat Hei = userVi.frame.size.height;
        UIView *delVi = [[UIView alloc]init];
        
        [userVi addSubview:delVi];
        
        [delVi anchorTopLeftWithLeftPadding:0 topPadding:0 width:25 height:userVi.height];
        
        delButton *delTag = [[delButton alloc]init];
        
        delTag.tView = tag;
        [delVi addSubview:delTag];
        
        [delTag setTitle:@"X" forState:UIControlStateNormal];
        [delTag setBackgroundColor:[UIColor redColor]];
        
        [delTag anchorInCenterWithWidth:20 height:20];
        
        [delTag addTarget:self action:@selector(removeTag:) forControlEvents:UIControlEventTouchUpInside];

        
        UIImageView *profileImage = [[UIImageView alloc] init];
        [profileImage setImageWithURL:[NSURL URLWithString:user.imageUrl]];
        profileImage.layer.masksToBounds = YES;
        [profileImage.layer setCornerRadius:(Hei-2*3)/2];
        
        [userVi addSubview:profileImage];
        
        [profileImage alignToTheRightOf:delVi withLeftPadding:10 topPadding:3 width:Hei-2*3 height:Hei-2*3];
        
        UILabel *nameLabel = [[UILabel alloc] init];
        [nameLabel setText:user.name];
        [userVi addSubview:nameLabel];
        
        [nameLabel alignToTheRightOf:profileImage matchingCenterAndFillingWidthWithLeftAndRightPadding:10 height:20];
        
        [views addObject:userVi];
    }
    
    [simpleView groupVertically:views centerWithSpacing:0 width:simpleView.frame.size.width height:size];
    
    _scrollView.contentSize = CGSizeMake(simpleView.frame.size.width, simpleView.frame.size.height+20);

}

- (void) removeTag:(delButton *)but {
    [self.delegate delTag:but.tView];
}

- (void) customView {
    
    //    [self setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *delButton = [[UIButton alloc]init];
    [delButton setBackgroundColor:[UIColor redColor]];
    [delButton setTitle:@"X" forState:UIControlStateNormal];
    delButton.layer.cornerRadius = 25/2;
    [delButton addTarget:self action:@selector(hideFriendsList) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:delButton];
    [delButton anchorTopRightWithRightPadding:5 topPadding:5 width:25 height:25];
    
    _scrollView = [UIScrollView new];
    [self addSubview:_scrollView];
    [_scrollView alignUnder:delButton centeredFillingWidthAndHeightWithLeftAndRightPadding:0 topAndBottomPadding:-(25/2)];
    _scrollView.layer.cornerRadius = 10;
    [_scrollView setBackgroundColor:[UIColor whiteColor]];
        [self bringSubviewToFront:delButton];
}

- (void) hideFriendsList {
    [self.delegate hideTagList:self];
}


- (void)show:(BOOL)show {
    self.shown = show;
    if(show) {
        [self.delegate showTagList:self];
    } else {
        [self.delegate hideTagList:self];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
