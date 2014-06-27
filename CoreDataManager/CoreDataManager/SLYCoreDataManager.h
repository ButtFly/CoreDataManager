//
//  SLYCoreDataManager.h
//  CoreDataManager
//
//  Created by 余河川 on 14-5-27.
//  Copyright (c) 2014年 com.315585758.www. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface SLYCoreDataManager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong, readonly) NSURL * modelURL;
@property (nonatomic, strong, readonly) NSURL * storeURL;
/**
@property (nonatomic, copy) NSDictionary * migrationOptions;
 */

/**
 创建并返回一个 'SLYCoreDataManager'。
 
 @param modelPath 数据模型文件的路径。
 */
+ (instancetype)managerWithManagedObjectModelPath:(NSString *)modelPath;

+ (instancetype)managerWithManagedObjectModelURL:(NSURL *)modelURL;

/**
 创建并返回一个 'SLYCoreDataManager'。
 
 @param resource 数据模型文件的名字（不包括文件后缀名，默认为momd）。
 @param storePath 数据存储文件的路径
 
 */

+ (instancetype)managerWithManagedObjectModelResource:(NSString *)resource;

+ (instancetype)managerWithManagedObjectModelPath:(NSString *)modelPath
                                     andStorePath:(NSString *)storePath;

+ (instancetype)managerWithManagedObjectModelURL:(NSURL *)modelURL
                                    andStorePath:(NSURL *)storeURL;

/**
 在使用之前，必须先调用此方法
 */
- (BOOL)prepare:(NSError **)error;

/**
 保存
 */
- (BOOL)saveContext:(NSError **)error;

/**
 查询
 */

- (NSManagedObject *)insertNewObjectForEntityForName:(NSString *)entityName;


@end
