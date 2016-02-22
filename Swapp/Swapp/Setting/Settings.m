//
//  Settings.m
//  Swapp
//
//  Created by Altimir Antonov on 9/13/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import "Settings.h"
#include <AssetsLibrary/AssetsLibrary.h>
#include "ApolloDB.h"


#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation Settings {
    NSArray *friendsList;
    NSArray *closefriendsList;
    //Array with names of the images that can be used
    NSMutableArray *imagesList;
    //Array with names of the images already used
    NSMutableArray *usedImageList;
    NSArray *ownImagesList;
}

#pragma mark - Class Methods

+ (Settings *)sharedInstance
{
    static Settings *settings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settings = [[Settings alloc] init];
    });
    return settings;
}

#pragma mark - Properties

static NSString *const kFriendKey = @"FBfriends";

- (NSArray *)friends
{
    return friendsList;
    //return [[NSUserDefaults standardUserDefaults] arrayForKey:kFriendKey];
    
}

-(NSArray *)closefriends
{
    return closefriendsList;
}

- (NSArray *)images {
    return imagesList;
}

- (void) addNewImages:(PHFetchResult *) imagList {
    //    if(!imagesList) {
    //        imagesList = [NSMutableArray new];
    //    }
    NSMutableArray *privateImagesList = [NSMutableArray new];
    NSMutableArray *arrayWithNames = [NSMutableArray new];
    NSLog(@"images to be added:\n %@", imagList);
    NSLog(@"already used images: \n %@", usedImageList);
    NSLog(@"images to bes used before: \n %@", imagList);
    
    CLS_LOG(@"The all Images: ");
    CLS_LOG(@"%@", imagList);
    
    CLS_LOG(@"The all Images name: ");
    CLS_LOG(@"%lu", (unsigned long)imagList.count);
    
    for( PHAsset *asset in imagList) {
        NSString *filename = asset.localIdentifier;
        
        if(filename) {
            [arrayWithNames addObject:filename];
//            NSURL *aURL= (NSURL*) [[imagList[i] defaultRepresentation]url];
            
//            NSString *path = [aURL absoluteString];
            if (![usedImageList containsObject:filename]) {
//                [dicWithImages setObject:path forKey:filename];
                
                [privateImagesList addObject:asset];
            }
        }
    }
    
    NSLog(@"images to bes used before: \n %@", imagList);
    //
    //    for (NSString *path in arr) {
    //        if (imagesList containsObject:path) {
    //
    //        }
    //    }
    //
    //    NSArray *newArray = [imagesList arrayByAddingObjectsFromArray:arr];
    //    imagesList = [NSMutableArray arrayWithArray:newArray];
    //    imagesList = [imagesList arrayByAddingObjectsFromArray:imagList]; //= newArray;
    
    //    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:imagesList.count];
    //    for (ALAsset *personObject in imagesList) {
    //        NSData *personEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:personObject];
    //        [archiveArray addObject:personEncodedObject];
    //    }
    //    [[ApolloDB sharedManager]setObject:imagesList forKey:@"ownImages"];
    
    NSLog(@"before: \n %@", privateImagesList);
    if(privateImagesList.count != 0) {
        imagesList = [NSMutableArray arrayWithArray:[self shuffle:privateImagesList]];
    }
}

- (void) setImageAsUsed: (PHAsset *) asset {
    
    CLS_LOG(@"image name that will be added as used: %@", asset.localIdentifier);
    if(![asset.localIdentifier isEqual:[NSNull null]]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [usedImageList addObject:asset.localIdentifier];
        [defaults setObject:usedImageList forKey:@"ownImages"];
        [defaults synchronize];
    }
    
}

- (void)setImages:(NSArray *)images {
    
    usedImageList = [NSMutableArray arrayWithArray:images];
}

- (NSArray *)ownImages {
    return ownImagesList;
}

- (void)setOwnImages:(NSArray *)ownImages {
    
    NSMutableArray *oi = [[NSMutableArray alloc] initWithArray:ownImages];
    ownImagesList = oi;
}

- (void)setFriends:(NSArray *)friends
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithArray:friends];
//    [ss addObjectsFromArray:friends];
//    [ss addObjectsFromArray:friends];
//    [ss addObjectsFromArray:friends];
    
    friendsList = ss;
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    [defaults setObject:friends forKey:kFriendKey];
    //    [defaults synchronize];
}

- (void)setClosefriends:(NSArray *)closefriends
{
    closefriendsList = closefriends;
}

- (NSArray *)shuffle:(NSMutableArray *)array {
    NSUInteger count = [array count];
    NSMutableArray *private = [NSMutableArray arrayWithArray:array];
    for (NSUInteger i = 0; i < count - 1; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [private exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
    
    return private;
}

@end
