//
//  tagView.h
//  Swapp
//
//  Created by Altimir Antonov on 7/26/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@protocol tagDelegate
- (void) deleteTag:(id)tag;
@end

@interface tagView : UIView
@property id<tagDelegate>delegate;
- (void) draw;
- (void) showUsername:(BOOL)show;
@property (nonatomic, assign) User *user;
@property (nonatomic,assign) CGPoint tagPosition;
@property (nonatomic, retain) NSString *imageUrl;
@property (nonatomic, assign) BOOL hasUser;


@end
