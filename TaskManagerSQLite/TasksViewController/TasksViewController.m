//
//  TasksViewController.m
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "TasksViewController.h"
#import "TaskTableViewCell.h"
#import "AddTaskViewController.h"
#import "SQLManager.h"

static NSString * const taskCellIdentifier = @"TaskTableViewCell";

@interface TasksViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<Task*> *dataSource;

@end

@implementation TasksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSource = [[NSMutableArray alloc] init];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    if ([[SQLManager sharedManager] initDatabase]) {
        NSLog(@"Success");
        NSArray *values = [[SQLManager sharedManager] selectAllTasks];
        
        for (NSDictionary *taskItem in values) {
            Task *task = [[Task alloc] init];
            
            task.id = ((NSString*)taskItem[@"id"]).intValue;
            task.name = taskItem[@"name"];
            task.details = taskItem[@"details"];
            task.iconName = taskItem[@"iconName"];
            task.expirationDate = [NSDate dateWithTimeIntervalSince1970:((NSString*)taskItem[@"expirationDate"]).doubleValue];
            
            [self.dataSource addObject:task];
        }
        
        [self.tableView reloadData];
    }
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) unwindSegue:(UIStoryboardSegue*) segue {
    if ([segue.identifier isEqualToString:@"unwindSegueToTasks"]) {
        
        AddTaskViewController *addTaskViewController = segue.sourceViewController;
        Task *newTask = addTaskViewController.task;
        
        if (newTask != nil) {
            [[SQLManager sharedManager] insertNewTask:newTask];
            
            NSDictionary *item = [[SQLManager sharedManager] selectLastRowID];
            int id = ((NSString *)item[@"id"]).intValue;
            newTask.id = id;
            
            [self.dataSource addObject:newTask];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(self.dataSource.count - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIContextualAction *delete = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        [[SQLManager sharedManager] deleteTask:self.dataSource[indexPath.row]];
        [self.dataSource removeObjectAtIndex:indexPath.row];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        completionHandler(YES);
    }];
    
    delete.backgroundColor = [UIColor colorWithRed:211.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1];
    delete.image = [UIImage imageNamed: @"trashImg"];
    
    return [UISwipeActionsConfiguration configurationWithActions:@[delete]];
}

@end
