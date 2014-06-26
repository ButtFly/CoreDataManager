//
//  SLYTest.h
//  CoreDataManager
//
//  Created by 余河川 on 14-5-28.
//  Copyright (c) 2014年 com.315585758.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLYTest : NSObject

@property (nonatomic, strong) NSMutableDictionary * testDic;
@property (nonatomic, copy) void(^testBlock)();

@end
