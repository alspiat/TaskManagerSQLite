//
//  AddTaskTableViewController.m
//  TaskManagerSQLite
//
//  Created by Алексей on 10.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "AddTaskTableViewController.h"
#import "IconCollectionViewCell.h"
#import "Task.h"

static NSString * const iconCollectionViewCell = @"IconCollectionViewCell";

@interface AddTaskTableViewController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSIndexPath *selectedIconIndex;
}

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UICollectionView *iconsCollectionView;

@property (strong, nonatomic) NSArray *icons;

@end

@implementation AddTaskTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    _icons = [[NSArray alloc] initWithObjects:@"ok", @"home", @"family", @"music", @"work", @"friends", @"shop", @"video", @"food", @"letter", nil];
    selectedIconIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    
    self.iconsCollectionView.dataSource = self;
    self.iconsCollectionView.delegate = self;
    
    [self.datePicker setValue:[UIColor colorWithRed:183.0/255.0 green:189.0/255.0 blue:201.0/255.0 alpha:1.0] forKey:@"textColor"];
    
    if (self.task != nil) {
        self.titleTextField.text = self.task.title;
        self.detailsTextView.text = self.task.details;
        
        self.datePicker.date = self.task.expirationDate;
        
        if (self.task.iconName) {
            NSLog(@"IconName: %@", self.task.iconName);
            selectedIconIndex = [NSIndexPath indexPathForRow:[self.icons indexOfObject:self.task.iconName] inSection:0];
        }
    } else {
        self.datePicker.minimumDate = [NSDate date];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonTapped:(UIBarButtonItem *)sender {
    
    if (self.task == nil) {
        _task = [[Task alloc] init];
    }
    
    self.task.title = self.titleTextField.text;
    self.task.details = self.detailsTextView.text;
    self.task.expirationDate = self.datePicker.date;
    
    if (selectedIconIndex != nil) {
        self.task.iconName = self.icons[selectedIconIndex.row];
    }
    
    [self performSegueWithIdentifier:@"unwindSegueToTasks" sender:self];
}

// MARK: - Table View DataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [super tableView:tableView numberOfRowsInSection:section];
}

// MARK: - Icons Collection View DataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.icons.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IconCollectionViewCell *iconCell = [collectionView dequeueReusableCellWithReuseIdentifier:iconCollectionViewCell forIndexPath:indexPath];
    
    [iconCell configureWithImage:[UIImage imageNamed:self.icons[indexPath.row]]];
    [iconCell setIsSelected: (indexPath == selectedIconIndex)];
    
    return iconCell;
}

// MARK: - Icons Collection View Delegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (selectedIconIndex != nil && selectedIconIndex.row != indexPath.row) {
        NSIndexPath *oldSelectedIndex = [NSIndexPath indexPathForRow:selectedIconIndex.row inSection:selectedIconIndex.section];
        
        selectedIconIndex = indexPath;
        [collectionView reloadItemsAtIndexPaths:@[oldSelectedIndex, selectedIconIndex]];
    } else {
        selectedIconIndex = indexPath;
        [collectionView reloadItemsAtIndexPaths:@[selectedIconIndex]];
    }
}

@end
