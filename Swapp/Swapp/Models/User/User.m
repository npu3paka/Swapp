//
//  User.m
//  Swapp
//
//  Created by Altimir Antonov on 9/13/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize name;
@synthesize userId;
@synthesize imageUrl;
@synthesize normal;

+ (instancetype)friendWithProperties:(NSDictionary*)tagInfo {
    return [[User alloc] initWithProperties:tagInfo];
}

- (id)initWithProperties:(NSDictionary *)tagInfo {
    self = [super init];
    if (self) {
        [self setUserId:tagInfo[@"userId"]];
        [self setName:tagInfo[@"name"]];
        [self setImageUrl:tagInfo[@"imageUrl"]];
        [self setNormal:[tagInfo[@"normal"] boolValue]];
    }
    return self;
}

- (NSString *)userId
{
    return userId;
}

- (NSString *)name
{
    return name;
}

- (NSString *)imageUrl
{
    return imageUrl;
}

-(BOOL)normal {
    return normal;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"User description:%@\n userId: %@\nname: %@\nimageUrl: %@\nnormal: %i\n",[super description], self.userId, self.name, self.imageUrl, self.normal];
}
@end
