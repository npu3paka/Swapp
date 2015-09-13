//
//  friendsList.h
//  Swapp
//
//  Created by Altimir Antonov on 7/23/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol friendListDelegate
- (void) deleteLastTag;
- (void) tagSelected:(id)info;
- (void) showList:(id)list;;
- (void) hideList:(id)list;
@end

@interface friendsList : UIView

@property (nonatomic, assign) BOOL shown;
- (void) customView;

- (void) addFriends: (NSArray *)fr;

- (void)show:(BOOL)show;

@property id<friendListDelegate>delegate;

@end
