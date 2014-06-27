//
//  SLYCoreDataManager.m
//  CoreDataManager
//
//  Created by 余河川 on 14-5-27.
//  Copyright (c) 2014年 com.315585758.www. All rights reserved.
//

#import "SLYCoreDataManager.h"

@interface SLYCoreDataManager ()

@property (nonatomic, strong, readonly) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;

@end

#define mark - Default values

static NSDictionary * defaultMigrationOptions()
{
    return @{
             NSMigratePersistentStoresAutomaticallyOption : @YES,
             NSInferMappingModelAutomaticallyOption : @YES
             };
};

@implementation SLYCoreDataManager

#pragma mark - Initialization

static BOOL kIsRightInit = NO;

+ (instancetype)managerWithManagedObjectModelPath:(NSString *)modelPath
{
    NSString * lastPathComponent = [modelPath lastPathComponent];
    NSURL * modelURL = [NSURL URLWithString:modelPath];
    NSURL * storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:lastPathComponent];
    return [self managerWithManagedObjectModelURL:modelURL andStorePath:storeURL];
}

+ (instancetype)managerWithManagedObjectModelURL:(NSURL *)modelURL
{
    NSString * lastPathComponent = [modelURL lastPathComponent];
    NSURL * storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:lastPathComponent];
    return [self managerWithManagedObjectModelURL:modelURL andStorePath:storeURL];
}

+ (instancetype)managerWithManagedObjectModelResource:(NSString *)resource
{
    NSURL * modelURL = [[NSBundle mainBundle] URLForResource:resource withExtension:@"momd"];
    NSURL * storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.CDBStore", resource]];
    return [self managerWithManagedObjectModelURL:modelURL andStorePath:storeURL];
}

+ (instancetype)managerWithManagedObjectModelPath:(NSString *)modelPath
                                     andStorePath:(NSString *)storePath
{
    NSURL * modelURL = [NSURL URLWithString:modelPath];
    NSURL * storeURL = [NSURL URLWithString:storePath];
    return [self managerWithManagedObjectModelURL:modelURL andStorePath:storeURL];
}

+ (instancetype)managerWithManagedObjectModelURL:(NSURL *)modelURL
                                    andStorePath:(NSURL *)storeURL
{
    return [[self alloc] initWithManagedObjectModelURL:modelURL andStoreURL:storeURL];
}

- (instancetype)initWithManagedObjectModelURL:(NSURL *)modelURL
                                     andStoreURL:(NSURL *)storeURL;
{
    kIsRightInit = YES;
    self = [self init];
    if (self) {
        _modelURL = modelURL;
        _storeURL = storeURL;
    }
    kIsRightInit = NO;
    return self;
}

- (id)init
{
    NSAssert(kIsRightInit, @"请不要直接用init初始化。");
    return [super init];
}

#pragma mark - Prepare

- (BOOL)prepare:(NSError *__autoreleasing *)error
{
    BOOL isSuccess = [self initManagedObjectModel:error];
    if (!isSuccess) {
        return isSuccess;
    }
    isSuccess = [self initPersistentStoreCoordinator:error];
    if (!isSuccess) {
        return isSuccess;
    }
    isSuccess = [self initManagerObjectContext:error];
    return isSuccess;
}

- (BOOL)initPersistentStoreCoordinator:(NSError *__autoreleasing *)error
{
    NSError * resultErr = nil;
    BOOL isSuccess = YES;
    if (_persistentStoreCoordinator) {
        isSuccess = NO;
        resultErr = [NSError errorWithDomain:@"SLYManagerDomain" code:1001 userInfo:nil];
    }
    else {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
        isSuccess = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:_storeURL
                                                        options:defaultMigrationOptions()
                                                          error:error
         ];
    }
    *error = resultErr;
    return isSuccess;
}

- (BOOL)initManagedObjectModel:(NSError *__autoreleasing *)error
{
    NSError * resultErr = nil;
    BOOL isSuccess = YES;
    if (_managedObjectModel) {
        isSuccess = NO;
        resultErr = [NSError errorWithDomain:@"SLYManagerDomain" code:1001 userInfo:nil];
    }
    else {
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:_modelURL];
        isSuccess = _managedObjectModel ? YES : NO;
    }
    return isSuccess;
}

- (BOOL)initManagerObjectContext:(NSError *__autoreleasing *)error
{
    NSError * resultErr = nil;
    BOOL isSuccess = YES;
    if (_managedObjectContext) {
        isSuccess = NO;
        resultErr = [NSError errorWithDomain:@"SLYManagerDomain" code:1001 userInfo:nil];
    }
    else {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
    }
    return isSuccess;
}

#pragma mark - Application's documents directory

// Returns the URL to the application's Documents directory.
+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - copy container

#pragma mark - insert

- (NSManagedObject *)insertNewObjectForEntityForName:(NSString *)entityName
{
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:_managedObjectContext];
}

#pragma mark - save

- (BOOL)saveContext:(NSError *__autoreleasing *)error
{
    if ([_managedObjectContext hasChanges]) {
        return [_managedObjectContext save:error];
    }
    else {
        return YES;
    }
}

@end
