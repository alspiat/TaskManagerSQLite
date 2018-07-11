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
#import "SQLManager.h"

static NSString * const taskCellIdentifier = @"TaskTableViewCell";

@interface TasksViewController () <UITableViewDataSource, UITableViewDelegate> {
    BOOL isSorted;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<Task*> *dataSource;

@end

@implementation TasksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSource = [[NSMutableArray alloc] init];
    
    isSorted = NO;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    if ([[SQLManager sharedManager] initDatabase]) {
        NSLog(@"Success");
        [self fillDatasourceFromDatabase];
        
        [self.tableView reloadData];
    }
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)longPressRecognized:(UILongPressGestureRecognizer *)sender {
    if (!self.tableView.isEditing) {
        [self.tableView setEditing: YES animated: YES];
    }
}

- (IBAction)rightSwipeRecognized:(UISwipeGestureRecognizer *)sender {
    if (self.tableView.isEditing) {
        [self.tableView setEditing: NO animated: YES];
    }
}

- (IBAction)sortButtonTapped:(UIBarButtonItem *)sender {
    if (!isSorted) {
        [self.dataSource sortUsingComparator:^NSComparisonResult(Task *task1, Task *task2) {
            return [task1.expirationDate compare:task2.expirationDate];
        }];
        
        isSorted = YES;
    } else {
        [self fillDatasourceFromDatabase];
        
        isSorted = NO;
    }
    [self.tableView reloadData];
}

- (IBAction)addButtonTapped:(UIBarButtonItem *)sender {
    
    AddTaskTableViewController *addTaskTVC = [[AddTaskTableViewController alloc] init];
    [self.navigationController pushViewController:addTaskTVC animated:YES];
    //[self presentViewController:navVC animated:YES completion:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToAddTask"] && self.tableView.indexPathForSelectedRow != nil) {
        UINavigationController *addTaskNavigationController = segue.destinationViewController;
        AddTaskTableViewController *addTaskTableViewController = addTaskNavigationController.viewControllers[0];
        addTaskTableViewController.task = self.dataSource[self.tableView.indexPathForSelectedRow.row];
    }
}

- (IBAction) unwindSegue:(UIStoryboardSegue*) segue {
    if ([segue.identifier isEqualToString:@"unwindSegueToTasks"]) {
        
        AddTaskTableViewController *addTaskTableViewController = segue.sourceViewController;
        Task *newTask = addTaskTableViewController.task;
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        
        if (newTask == nil) {
            return;
        }
        
        if (newTask.id) {
            NSLog(@"Update");
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [[SQLManager sharedManager] updateTask:newTask];
        } else {
            [[SQLManager sharedManager] insertNewTask:newTask];
            
            NSDictionary *item = [[SQLManager sharedManager] selectLastRowID];
            
            if (item != nil) {
                int id = ((NSString *)item[@"id"]).intValue;
                newTask.id = id;
                
                [self.dataSource addObject:newTask];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(self.dataSource.count - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)fillDatasourceFromDatabase {
    
    [self.dataSource removeAllObjects];
    NSArray *values = [[SQLManager sharedManager] selectAllTasks];
    
    if (values == nil) {
        return;
    }
    
    for (NSDictionary *taskItem in values) {
        Task *task = [[Task alloc] init];
        
        task.id = ((NSString*)taskItem[@"id"]).intValue;
        task.title = taskItem[@"title"];
        task.details = taskItem[@"details"];
        task.iconName = taskItem[@"iconName"];
        task.isDone = ((NSString*)taskItem[@"isDone"]).boolValue;
        task.expirationDate = [NSDate dateWithTimeIntervalSince1970:((NSString*)taskItem[@"expirationDate"]).doubleValue];
        
        [self.dataSource addObject:task];
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
        
        [[SQLManager sharedManager] deleteTask:self.dataSource[indexPath.row]];
        [self.dataSource removeObjectAtIndex:indexPath.row];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        completionHandler(YES);
    }];
    
    delete.backgroundColor = [UIColor colorWithRed:211.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1];
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
        [[SQLManager sharedManager] updateTask:self.dataSource[indexPath.row]];
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        completionHandler(YES);
    }];
    
    selectAsDone.backgroundColor = [UIColor colorWithRed:36.0/255.0 green:110.0/255.0 blue:95.0/255.0 alpha:1];
    selectAsDone.image = [UIImage imageNamed: imageName];
    
    return [UISwipeActionsConfiguration configurationWithActions:@[selectAsDone]];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        return UITableViewCellEditingStyleNone;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.dataSource exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    
    int id1 = self.dataSource[sourceIndexPath.row].id;
    int id2 = self.dataSource[destinationIndexPath.row].id;
    
    self.dataSource[sourceIndexPath.row].id = id2;
    self.dataSource[destinationIndexPath.row].id = id1;
    
    [[SQLManager sharedManager] swapTaskID:id1 toTaskID:-1];
    [[SQLManager sharedManager] swapTaskID:id2 toTaskID:id1];
    [[SQLManager sharedManager] swapTaskID:-1 toTaskID:id2];
}

@end
