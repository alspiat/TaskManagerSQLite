//
//  AddTaskViewController.m
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "AddTaskViewController.h"
#import "Task.h"

@interface AddTaskViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation AddTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.detailsTextView.layer setCornerRadius:5];
    [self.detailsTextView.layer setBorderWidth:0.4];
    self.detailsTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonTapped:(UIButton *)sender {
    _task = [[Task alloc] init];
    
    self.task.name = self.nameTextField.text;
    self.task.details = self.detailsTextView.text;
    self.task.expirationDate = self.datePicker.date;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
