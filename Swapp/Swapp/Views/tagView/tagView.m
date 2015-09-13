//
//  tagView.m
//  Swapp
//
//  Created by Altimir Antonov on 7/26/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import "tagView.h"
#import "UIView+Ext.h"

@implementation tagView {
    User *us;
    UILabel *username;
    UIView *square;
    UIButton *deleteButton;
}

- (void) draw {
    self.hasUser = NO;
    //self.layer.borderWidth = 2;
    // Drawing code
    
    deleteButton = [[UIButton alloc]init];
    [deleteButton setBackgroundColor:[UIColor redColor]];
    
    deleteButton.layer.cornerRadius = 10/2;
    
    [deleteButton setFrame:CGRectMake(self.frame.size.width-15, 5, 10, 10)];
    [deleteButton setTitle:@"X" forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.clipsToBounds = YES;
    square = [[UIView alloc] init];
    [self addSubview:square];
    
    CGFloat smallHeight = self.width/2;
    
    if(self.height * 0.7 < self.width/2) {
        smallHeight = self.height * 0.7;
    }
    
    [square anchorTopCenterWithTopPadding:0 width:smallHeight height:smallHeight];
//    [square anchorTopCenterFillingWidthWithLeftAndRightPadding:0 topPadding:0 height:self.height*0.7];
    square.layer.borderWidth = 2;
    
    square.layer.borderColor = [[UIColor greenColor] CGColor];
    
    square.layer.cornerRadius = smallHeight / 2;
    
    username = [[UILabel alloc] init];
    
    [username setText:us.name];
    [self addSubview:username];
    
    [username alignUnder:square centeredFillingWidthWithLeftAndRightPadding:0 topPadding:0 height:20];

    username.layer.cornerRadius = username.height/2;
    username.clipsToBounds = YES;
    
    deleteButton.hidden = YES;

    [self addSubview:deleteButton];

}

- (void) showUsername:(BOOL)show {
    username.hidden = !show;
}

- (User *)user {
    return us;
}

- (void)setUser:(User *)user {
    self.hasUser = YES;
    square.hidden = YES;
    us = user;
    [username setFont: [username.font fontWithSize: 10]];
    username.textAlignment = NSTextAlignmentCenter;
    [username setBackgroundColor:[UIColor colorWithRed:80 green:80 blue:80 alpha:0.8]];
    [username setText:us.name];
}

- (void)delete {
    [self.delegate deleteTag:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (NSString *)description
{
    return [NSString stringWithFormat:@"tagView description:%@\n user: %@\ntagPosition: %@\n",[super description], [self.user description], NSStringFromCGPoint(self.tagPosition)];
}

@end
