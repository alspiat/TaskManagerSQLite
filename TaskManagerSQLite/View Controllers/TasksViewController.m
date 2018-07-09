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
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) unwindSegue:(UIStoryboardSegue*) segue {
    if ([segue.identifier isEqualToString:@"unwindSegueToTasks"]) {
        
        AddTaskViewController *addTaskViewController = segue.sourceViewController;
        if (addTaskViewController.task != nil) {
            [self.dataSource addObject:addTaskViewController.task];
            [self.tableView reloadData]; // ----------------------
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
    TaskTableViewCell *taskCell = [self.tableView dequeueReusableCellWithIdentifier: taskCellIdentifier];
    [taskCell configureCellWithTask:self.dataSource[indexPath.row]];
    
    return taskCell;
}

// MARK: - Table View Delegate methods

@end
