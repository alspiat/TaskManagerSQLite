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
#import "UIColor+ApplicationColors.h"
#import "StoreType.h"
#import "Constants.h"

@interface TasksViewController () <UITableViewDataSource, UITableViewDelegate, AddTaskViewControllerDelegate> {
    BOOL isSorted;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray<Task *> *dataSource;
@property (strong, nonatomic) id<TaskServiceProtocol> taskService;

@end

@implementation TasksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isSorted = NO;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    _dataSource = [[NSMutableArray alloc] init];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    StoreType storeType = [userDefaults integerForKey:SettingsStoreType];
    
    [TaskServiceProvider.sharedProvider setStoreType:storeType];
    self.taskService = [TaskServiceProvider.sharedProvider getCurrentService];
    
    [self.dataSource addObjectsFromArray:[self.taskService getAllTasks]];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateTableView) name:storeDidUpdateNotification object:nil];
    
    
    // Do any additional setup after loading the view.
}

- (void) updateTableView {
    self.taskService = [TaskServiceProvider.sharedProvider getCurrentService];
    
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:[self.taskService getAllTasks]];
    
    [self.tableView reloadData];
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
    if ([segue.identifier isEqualToString:segueToAddTaskController]) {
        UINavigationController *addTaskNavigationController = segue.destinationViewController;
        AddTaskTableViewController *addTaskTableViewController = addTaskNavigationController.viewControllers[0];
        addTaskTableViewController.delegate = self;
        
        if (self.tableView.indexPathForSelectedRow != nil) {
            addTaskTableViewController.task = self.dataSource[self.tableView.indexPathForSelectedRow.row];
        }
        
    }
}

- (IBAction)unwindSegue:(UIStoryboardSegue*) segue {
    if ([segue.identifier isEqualToString:unwindSegueToTasksController]) {
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

// MARK: - AddTaskViewController delegate methods

- (void)addNewTask:(Task *)task {
    [self.dataSource addObject:task];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(self.dataSource.count - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)updateTask:(Task *)task {
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

// MARK: - Table View datasource methods

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
    [self performSegueWithIdentifier:segueToAddTaskController sender:self];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIContextualAction *delete = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        [self.taskService deleteTask:self.dataSource[indexPath.row]];
        [self.dataSource removeObjectAtIndex:indexPath.row];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        completionHandler(YES);
    }];
    
    delete.backgroundColor = [UIColor appDeleteRowActionColor];
    delete.image = [UIImage imageNamed: deleteImageName];
    
    return [UISwipeActionsConfiguration configurationWithActions:@[delete]];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *title;
    NSString *imageName;
    BOOL value;
    
    if (self.dataSource[indexPath.row].isDone) {
        title = @"Undone";
        imageName = undoneImageName;
        value = NO;
    } else {
        title = @"Done";
        imageName = doneImageName;
        value = YES;
    }
    
    UIContextualAction *selectAsDone = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:title handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        self.dataSource[indexPath.row].isDone = value;
        [self.taskService updateTask:self.dataSource[indexPath.row]];
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        completionHandler(YES);
    }];
    
    selectAsDone.backgroundColor = [UIColor appDoneRowActionColor];
    selectAsDone.image = [UIImage imageNamed: imageName];
    
    return [UISwipeActionsConfiguration configurationWithActions:@[selectAsDone]];
}

@end
