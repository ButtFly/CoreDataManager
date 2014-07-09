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
@property (nonatomic, strong, readonly) NSManagedObjectContext * managedObjectContext;
/**
@property (nonatomic, strong, readonly) NSMutableDictionary * managedObjectContexts;
 */

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
    BOOL isSuccess = YES;
    if (_persistentStoreCoordinator) {
        isSuccess = NO;
        *error = [NSError errorWithDomain:@"SLYManagerDomain" code:1001 userInfo:nil];
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
    return isSuccess;
}

- (BOOL)initManagedObjectModel:(NSError *__autoreleasing *)error
{
    BOOL isSuccess = YES;
    if (_managedObjectModel) {
        isSuccess = NO;
        *error = [NSError errorWithDomain:@"SLYManagerDomain" code:1001 userInfo:nil];
    }
    else {
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:_modelURL];
        isSuccess = _managedObjectModel ? YES : NO;
    }
    return isSuccess;
}

- (BOOL)initManagerObjectContext:(NSError *__autoreleasing *)error
{
    BOOL isSuccess = YES;
    if (_managedObjectContext) {
        isSuccess = NO;
        *error = [NSError errorWithDomain:@"SLYManagerDomain" code:1001 userInfo:nil];
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

#pragma mark - Execute fetch

- (NSManagedObject *)insertNewObjectForEntityForName:(NSString *)entityName
{
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:_managedObjectContext];
}

- (void)deleteObject:(NSManagedObject *)object
{
    [_managedObjectContext deleteObject:object];
}

- (BOOL)saveContext:(NSError *__autoreleasing *)error
{
    if ([_managedObjectContext hasChanges]) {
        return [_managedObjectContext save:error];
    }
    else {
        return YES;
    }
}

- (NSManagedObjectContext *)defaultManagedObjectContext
{
    return _managedObjectContext;
}

- (NSArray *)objectsWithFetchRequest:(NSFetchRequest *)fetchRequest error:(NSError *__autoreleasing *)error
{
    return [_managedObjectContext executeFetchRequest:fetchRequest error:error];
}

- (NSArray *)objectsWithValue:(id)value forKeyPath:(id)keyPath forEntityForName:(NSString *)entityName error:(NSError *__autoreleasing *)error
{
    return [self objectsWithProperties:@{keyPath: value} forEntityForName:entityName error:error];
}

- (NSArray *)objectsWithProperties:(NSDictionary *)properties forEntityForName:(NSString *)entityName error:(NSError *__autoreleasing *)error
{
    return [self objectsWithProperties:properties forEntityForName:entityName fetchLimit:0 fetchOffset:0 sortDescriptors:nil error:error];
}

- (NSArray *)objectsWithProperties:(NSDictionary *)properties forEntityForName:(NSString *)entityName fetchLimit:(NSUInteger)fetchLimit fetchOffset:(NSUInteger)fetchOffset sortDescriptors:(NSArray *)sortDescriptors error:(NSError *__autoreleasing *)error
{
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSMutableString * formatStr = [NSMutableString stringWithFormat:@""];
    NSMutableDictionary * variables = [NSMutableDictionary dictionary];
    [properties.allKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = [properties objectForKey:obj];
        if ([value isKindOfClass:[NSString class]]) {
            [formatStr appendFormat:@"&& %@ == \"%@\"", obj, value];
        }
        else if ([value isKindOfClass:[NSValue class]]) {
            [formatStr appendFormat:@"&& %@ == %@", obj, value];
        }
        else if ([value isKindOfClass:[NSDate class]]) {
            [formatStr appendFormat:@"&& %@ == $%@", obj, obj];
            [variables setObject:value forKey:obj];
        }
        if (!idx) {
            [formatStr deleteCharactersInRange:NSMakeRange(0, 3)];
        }
    }];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:formatStr];
    [request setPredicate:[predicate predicateWithSubstitutionVariables:variables]];
    [request setFetchLimit:fetchLimit];
    [request setFetchOffset:fetchOffset];
    [request setSortDescriptors:sortDescriptors];
    return [self objectsWithFetchRequest:request error:error];
}

@end
