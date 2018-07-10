//
//  AddTaskViewController.m
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "AddTaskViewController.h"
#import "Task.h"
#import "IconCollectionViewCell.h"

static NSString * const iconCollectionViewCell = @"IconCollectionViewCell";

@interface AddTaskViewController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSIndexPath *selectedIconIndex;
}

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UICollectionView *iconsCollectionView;

@property (strong, nonatomic) NSArray *icons;

@end

@implementation AddTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _icons = [[NSArray alloc] initWithObjects:@"ask", @"attention", @"car", @"chair", @"coffee", @"home", @"light", @"pc", @"plane", @"shop", nil];
    
    [self.detailsTextView.layer setCornerRadius:5];
    [self.detailsTextView.layer setBorderWidth:0.4];
    self.detailsTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.iconsCollectionView.dataSource = self;
    self.iconsCollectionView.delegate = self;
    
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
    
    // Do any additional setup after loading the view.
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

// MARK: - Icons Collection View DataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.icons.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IconCollectionViewCell *iconCell = [collectionView dequeueReusableCellWithReuseIdentifier:iconCollectionViewCell forIndexPath:indexPath];
    [iconCell configureWithImage:[UIImage imageNamed:self.icons[indexPath.row]]];
    
    if (indexPath == selectedIconIndex) {
        [iconCell.iconImageView.layer setBorderWidth:2];
    } else {
        [iconCell.iconImageView.layer setBorderWidth:0];
    }
    
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
