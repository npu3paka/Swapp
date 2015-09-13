//
//  friendsList.m
//  Swapp
//
//  Created by Altimir Antonov on 7/23/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import "friendsList.h"
#import "User.h"
#import "UIView+Ext.h"
#import "UIKit+AFNetworking.h"
#import "FriendRow.h"
#import "NHMainHeader.h"
#import "Settings.h"

@interface friendsList() <NHAutoCompleteTextFieldDataSourceDelegate, NHAutoCompleteTextFieldDataFilterDelegate>{
    NHAutoCompleteTextField *autoCompleteTextField;
    NSArray *inUseDataSource;
    Settings *settings;
}

@end

@implementation friendsList {
    NSArray *friends;
}

#define kCellIdentifier @"cellIdentifier"

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.shown = NO;
    
    return self;
}

- (void) addFriends: (NSArray *)fr {
    friends = fr;
    inUseDataSource = fr;
}

- (void) customView {
    
    settings = [Settings sharedInstance];

    CGFloat controlWidth = 200;

    autoCompleteTextField = [[NHAutoCompleteTextField alloc] initWithFrame:CGRectMake((kScreenSize.width - controlWidth) / 2, 120, controlWidth, 18)];
    [autoCompleteTextField setDropDownDirection:NHDropDownDirectionDown];
    [autoCompleteTextField setDataSourceDelegate:self];
    [autoCompleteTextField setDataFilterDelegate:self];
    
    [self addSubview:autoCompleteTextField];
    
    inUseDataSource = settings.friends;
}

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    //[self.delegate tagSelected:recognizer.view];
}

- (void) hideFriendsList {
    [self.delegate deleteLastTag];
}

- (void)show:(BOOL)show {
    self.shown = show;
}


@end
