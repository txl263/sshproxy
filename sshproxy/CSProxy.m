//
//  CSProxy.m
//  sshproxy
//
//  Created by Brant Young on 3/2/14.
//  Copyright (c) 2014 Charm Studio. All rights reserved.
//

#import "CSProxy.h"

@implementation CSProxy

- (instancetype)init
{
    self = [super init];
    if (self) {
        // default values
        self.proxy_id    = CSGenerateUniqueId();
    }
    return self;
}

@end