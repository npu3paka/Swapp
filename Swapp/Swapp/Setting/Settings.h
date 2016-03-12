//
//  Settings.h
//  Swapp
//
//  Created by Altimir Antonov on 9/13/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@import Photos;

@interface Settings : NSObject
+ (Settings *)sharedInstance;

@property (nonatomic, strong) User *current_user;
@property (nonatomic, assign) NSArray *friends;
@property (nonatomic, assign) NSArray *closefriends;
@property (nonatomic, assign) NSArray *images;


@property (nonatomic, strong) NSMutableOrderedSet *photos;

@property (nonatomic, assign) NSArray *dwImages;

//@property (nonatomic, assign) NSDictionary *dicImages;
@property (nonatomic, assign) NSArray *ownImages;

@property (nonatomic, strong) NSString *selectedImageId;
@property (nonatomic, strong) NSString *selectedImageUrl;


@property (nonatomic, strong) NSString *recSwCount;
@property (nonatomic, strong) NSString *sentSwCount;




- (void) addNewImages:(PHFetchResult *) imagList;
- (void) setImageAsUsed: (PHAsset *) asset;

@end
