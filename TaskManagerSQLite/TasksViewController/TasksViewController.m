//
//  TasksViewController.m
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "TasksViewController.h"
#import "TaskTableViewCell.h"
#import "AddTaskTableViewController.h"
#import "Task.h"
#import "TaskServiceProvider.h"
#import "StoreType.h"

static NSString * const taskCellIdentifier = @"TaskTableViewCell";

@interface TasksViewController () <UITableViewDataSource, UITableViewDelegate> {
    BOOL isSorted;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray<Task *> *dataSource;
@property (strong, nonatomic) id<TaskServiceProtocol> taskService;

@property (assign, nonatomic) StoreType currentStoreType;

@end

@implementation TasksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isSorted = NO;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    _dataSource = [[NSMutableArray alloc] init];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.currentStoreType = [userDefaults integerForKey:SettingsStoreType];
    
    NSLog(@"Load storeType: %@", self.currentStoreType == StoreTypeCoreData ? @"StoreTypeCoreData" : @"StoreTypeSQLite");
    
    [TaskServiceProvider.sharedProvider setStoreType:self.currentStoreType];
    self.taskService = [TaskServiceProvider.sharedProvider getCurrentService];
    
    [self.dataSource addObjectsFromArray:[self.taskService getAllTasks]];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (TaskServiceProvider.sharedProvider.storeType != self.currentStoreType) {
        NSLog(@"Update storeType to %@", TaskServiceProvider.sharedProvider.storeType == StoreTypeCoreData ? @"StoreTypeCoreData" : @"StoreTypeSQLite");
        
        self.currentStoreType = TaskServiceProvider.sharedProvider.storeType;
        self.taskService = [TaskServiceProvider.sharedProvider getCurrentService];
        
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:[self.taskService getAllTasks]];
        
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sortButtonTapped:(UIBarButtonItem *)sender {
    if (!isSorted) {
        [self.dataSource sortUsingComparator:^NSComparisonResult(Task *task1, Task *task2) {
            return [task1.expirationDate compare:task2.expirationDate];
        }];

        isSorted = YES;
    } else {
        self.dataSource = [NSMutableArray arrayWithArray:[self.taskService getAllTasks]];

        isSorted = NO;
    }
    [self.tableView reloadData];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToAddTask"] && self.tableView.indexPathForSelectedRow != nil) {
        UINavigationController *addTaskNavigationController = segue.destinationViewController;
        AddTaskTableViewController *addTaskTableViewController = addTaskNavigationController.viewControllers[0];
        addTaskTableViewController.task = self.dataSource[self.tableView.indexPathForSelectedRow.row];
    }
}

- (IBAction)unwindSegue:(UIStoryboardSegue*) segue {
    if ([segue.identifier isEqualToString:@"unwindSegueToTasks"]) {
        
        AddTaskTableViewController *addTaskTableViewController = segue.sourceViewController;
        Task *newTask = addTaskTableViewController.task;
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        
        if (newTask == nil) {
            return;
        }
        
        if (newTask.id) {
            //NSLog(@"Update");
            [self.taskService updateTask:newTask];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            //NSLog(@"New task");
            newTask.id = [self.taskService getLastTaskID] + 1;
            [self.taskService addTask:newTask];
            [self.dataSource addObject:newTask];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(self.dataSource.count - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

// MARK: - Table View DataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskTableViewCell *taskCell = [tableView dequeueReusableCellWithIdentifier: taskCellIdentifier];
    [taskCell configureCellWithTask:self.dataSource[indexPath.row]];
    
    return taskCell;
}

// MARK: - Table View Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"segueToAddTask" sender:self];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIContextualAction *delete = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        [self.taskService deleteTask:self.dataSource[indexPath.row]];
        [self.dataSource removeObjectAtIndex:indexPath.row];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        completionHandler(YES);
    }];
    
    //delete.backgroundColor = [self.colorService colorForDeleteRowAction];
    delete.image = [UIImage imageNamed: @"delete"];
    
    return [UISwipeActionsConfiguration configurationWithActions:@[delete]];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *title;
    NSString *imageName;
    BOOL value;
    
    if (self.dataSource[indexPath.row].isDone) {
        title = @"Undone";
        imageName = @"undone";
        value = NO;
    } else {
        title = @"Done";
        imageName = @"done";
        value = YES;
    }
    
    UIContextualAction *selectAsDone = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:title handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        self.dataSource[indexPath.row].isDone = value;
        [self.taskService updateTask:self.dataSource[indexPath.row]];
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        completionHandler(YES);
    }];
    
    selectAsDone.backgroundColor = [UIColor colorWithRed:36.0/255.0 green:110.0/255.0 blue:95.0/255.0 alpha:1];
    selectAsDone.image = [UIImage imageNamed: imageName];
    
    return [UISwipeActionsConfiguration configurationWithActions:@[selectAsDone]];
}

@end
