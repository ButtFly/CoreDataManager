//
//  SLYTest.m
//  CoreDataManager
//
//  Created by 余河川 on 14-5-28.
//  Copyright (c) 2014年 com.315585758.www. All rights reserved.
//

#import "SLYTest.h"


@implementation SLYTest

@synthesize testDic = _testDic;

- (void)setTestDic:(NSMutableDictionary *)testDic
{
    self.testBlock();
    _testDic = [testDic mutableCopy];
}

- (NSMutableDictionary *)testDic
{
    return [_testDic mutableCopy];
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
