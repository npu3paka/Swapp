//
//  taggedList.h
//  Swapp
//
//  Created by Altimir Antonov on 7/28/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "tagView.h"

@protocol taggedListDelegate
- (void) delTag:(id)info;
- (void) tagSelected:(id)info;
- (void) showTagList:(id)list;;
- (void) hideTagList:(id)list;
@end

@interface taggedList : UIView

@property (nonatomic, assign) BOOL shown;
- (void) customView;

- (void) addTags: (NSArray *)fr;

- (void)show:(BOOL)show;

@property id<taggedListDelegate>delegate;


@end
