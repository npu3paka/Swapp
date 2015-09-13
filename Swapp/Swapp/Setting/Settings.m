//
//  Settings.m
//  Swapp
//
//  Created by Altimir Antonov on 9/13/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import "Settings.h"

@implementation Settings {
    NSArray *friendsList;
    NSArray *closefriendsList;
    NSArray *imagesList;
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

- (void)setImages:(NSArray *)images {
    imagesList = images;
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
    //[ss addObjectsFromArray:friends];
    
    friendsList = ss;
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    [defaults setObject:friends forKey:kFriendKey];
    //    [defaults synchronize];
}

- (void)setClosefriends:(NSArray *)closefriends
{
    closefriendsList = closefriends;
}

@end
