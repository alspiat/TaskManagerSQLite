//
//  AddTaskViewController.m
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "AddTaskViewController.h"
#import "Task.h"
#import "MarkCollectionViewCell.h"

static NSString * const markCollectionViewCell = @"MarkCollectionViewCell";

@interface AddTaskViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UICollectionView *marksCollectionView;

@property (strong, nonatomic) NSArray *marks;

@end

@implementation AddTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _marks = [[NSArray alloc] initWithObjects:@"family", @"friends", @"home", @"work", @"pc", nil];
    
    [self.detailsTextView.layer setCornerRadius:5];
    [self.detailsTextView.layer setBorderWidth:0.4];
    self.detailsTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.datePicker.minimumDate = [NSDate date];
    
    self.marksCollectionView.dataSource = self;
    self.marksCollectionView.delegate = self;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonTapped:(UIBarButtonItem *)sender {
    _task = [[Task alloc] init];
    
    self.task.name = self.nameTextField.text;
    self.task.details = self.detailsTextView.text;
    self.task.expirationDate = self.datePicker.date;
    
    if (self.marksCollectionView.indexPathsForSelectedItems.lastObject != nil) {
        self.task.iconName = self.marks[self.marksCollectionView.indexPathsForSelectedItems.lastObject.row];
    }
    
    [self performSegueWithIdentifier:@"unwindSegueToTasks" sender:self];
}

// MARK: - Marks Collection View DataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.marks.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MarkCollectionViewCell *markCell = [collectionView dequeueReusableCellWithReuseIdentifier:markCollectionViewCell forIndexPath:indexPath];
    [markCell configureWithImage:[UIImage imageNamed:self.marks[indexPath.row]]];
    return markCell;
}

// MARK: - Marks Collection View Delegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MarkCollectionViewCell *markCell = [collectionView cellForItemAtIndexPath:indexPath];    
    [markCell.markImageView.layer setBorderWidth:2];
}

@end
