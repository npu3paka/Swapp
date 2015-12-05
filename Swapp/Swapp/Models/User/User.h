//
//  User.h
//  Swapp
//
//  Created by Altimir Antonov on 9/13/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
+ (instancetype)friendWithProperties:(NSDictionary*)tagInfo;
- (id)initWithProperties:(NSDictionary *)tagInfo;

@property (nonatomic,strong) NSString *userId;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *imageUrl;
@property (nonatomic,assign) BOOL normal;
@property (nonatomic,assign) BOOL newReg;


@end
