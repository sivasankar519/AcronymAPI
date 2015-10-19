//
//  AcronymsTableViewController.m
//  AcronymsAPI
//
//  Created by SIVASANKAR DEVABATHINI on 10/19/15.
//  Copyright (c) 2015 SIVASANKAR DEVABATHINI. All rights reserved.
//

#import "AcronymsTableViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

static NSString * const baseURL = @"http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=%@";
static NSString * const largeContentURL = @"http://a1591.phobos.apple.com/us/r1000/089/Music/52/c7/7c/mzm.aptpjmtx.aac.p.m4a";

@interface AcronymsTableViewController ()
{
    NSArray *detailInfo;
    MBProgressHUD *HUD;
}
@end

@implementation AcronymsTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self fectchDataForAcrynm:self.searchString];
    self.title = self.searchString;
    if(!HUD){
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.labelText = @"Loading";
        HUD.removeFromSuperViewOnHide = YES;
        
        // if contente in URL is large, use Determinate mode
        // HUD.mode = MBProgressHUDModeDeterminate;
    }
    [HUD show:YES];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)fectchDataForAcrynm:(NSString*)acrynm{
    
   
    NSString *urlString = [NSString stringWithFormat:baseURL,acrynm];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
   
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    /*
    // Set a download progress block for the operation for large content url
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float value =  (float) totalBytesRead/totalBytesExpectedToRead;
        HUD.progress = value;
        
    }];
    */
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *error;
        HUD.hidden = YES;
        detailInfo = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
        if(detailInfo.count){
            detailInfo = [[NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error][0] valueForKey:@"lfs"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error in Retrieving Acronyms"
                                                                message:@"No Data Found"
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
       
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error in Retrieving Acronyms"
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
   
    [operation start];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return [detailInfo count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = detailInfo[indexPath.row][@"lf"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@" usage frequency is %@, since %@",
                                 detailInfo[indexPath.row][@"freq"] ,
                                  detailInfo[indexPath.row][@"since"]];
   
    return cell;
}

@end
