//
//  SLYViewController.m
//  CoreDataManager
//
//  Created by 余河川 on 14-5-27.
//  Copyright (c) 2014年 com.315585758.www. All rights reserved.
//

#import "SLYViewController.h"
#import "SLYCoreDataManager.h"
#import "SLYTest.h"

@interface SLYViewController () <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) SLYCoreDataManager * manager;
@property (nonatomic, strong) NSFetchedResultsController * resultsController;

@end

@implementation SLYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.manager = [SLYCoreDataManager managerWithManagedObjectModelResource:@"Model"];
    NSError * error;
    [_manager prepare:&error];
    [self prepareFetchedResultsController];
}

- (void)prepareFetchedResultsController
{
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"People"];
    NSSortDescriptor * nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[nameSort]];
    self.resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[_manager defaultManagedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    [_resultsController setDelegate:self];
    [_resultsController performFetch:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addAction:(UIButton *)sender
{
    NSManagedObject * newPeople = [_manager insertNewObjectForEntityForName:@"People"];
    [newPeople setValue:@"Li" forKeyPath:@"name"];
    [newPeople setValue:[NSDate dateWithTimeIntervalSince1970:0] forKey:@"birthday"];
    [newPeople setValue:@108.888888888888 forKey:@"height"];
}
- (IBAction)selectAction:(UIButton *)sender
{
    NSArray * results = [_manager objectsWithValue:@"Li" forKeyPath:@"name" forEntityForName:@"People" error:nil];
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"%lu, %@", (unsigned long)idx, [obj valueForKeyPath:@"name"]);
    }];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSLog(@"%@", [anObject valueForKeyPath:@"name"]);
    NSError * error;
    [_manager saveContext:&error];
    NSLog(@"%@", error);
}



@end
