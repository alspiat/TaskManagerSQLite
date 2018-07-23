//
//  SettingsViewController.m
//  TaskManagerSQLite
//
//  Created by Aliaksei Piatyha on 7/17/18.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "SettingsViewController.h"
#import "TaskServiceProvider.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *storeSegmentedControl;
@property (strong, nonatomic) NSUserDefaults *userDefaults;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.storeSegmentedControl addTarget:self action:@selector(segmentedControlChangeValue:) forControlEvents:UIControlEventValueChanged];
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
    [self.storeSegmentedControl setSelectedSegmentIndex: [self.userDefaults integerForKey:SettingsStoreType]];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)segmentedControlChangeValue:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if (self.storeSegmentedControl.selectedSegmentIndex == 0) {
        [TaskServiceProvider.sharedProvider setStoreType:StoreTypeSQLite];
        [userDefault setInteger:StoreTypeSQLite forKey:SettingsStoreType];
    } else {
        [TaskServiceProvider.sharedProvider setStoreType:StoreTypeCoreData];
        [userDefault setInteger:StoreTypeCoreData forKey:SettingsStoreType];
    }
    
}

- (IBAction)deleteAll:(UIButton *)sender {
    [TaskServiceProvider.sharedProvider clearStores];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Clearing completed" message:@"Clearing completed successfully" preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)synchronize:(UIButton *)sender {
    TaskServiceProvider *taskService = TaskServiceProvider.sharedProvider;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose priority store" message:@"Choose priority store if there are update collisions" preferredStyle: UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cdAction = [UIAlertAction actionWithTitle:@"CoreData" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [taskService synchronizeWithPriority: StoreTypeCoreData];
    }];
    
    UIAlertAction *slAction = [UIAlertAction actionWithTitle:@"SQLLite" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [taskService synchronizeWithPriority: StoreTypeSQLite];
    }];
    
    [alertController addAction:cdAction];
    [alertController addAction:slAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
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
