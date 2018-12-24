//
//  OrgSyncViewController.m
//  GuiZhouRMMobile
//
//  Created by yu hongwu on 12-10-15.
//
//

#import "OrgSyncViewController.h"
#import "AGAlertViewWithProgressbar.h"
#import "ServiceListViewController.h"


@interface OrgSyncViewController ()
- (void)downLoadFinished;
@end

@implementation OrgSyncViewController
@synthesize textServerAddress = _textServerAddress;
@synthesize dataDownLoader = _dataDownLoader;

- (DataDownLoad *)dataDownLoader{
    _dataDownLoader = nil;
    if (_dataDownLoader == nil) {
        _dataDownLoader = [[DataDownLoad alloc] init];
    }
    return _dataDownLoader;
}

- (void)viewDidLoad
{
    self.textServerAddress.text = [[AppDelegate App] serverAddress];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.serviceTextField.placeholder = @"广佛肇";
}

- (void)viewDidDisappear:(BOOL)animated{
    self.dataDownLoader = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DOWNLOADFINISHNOTI object:nil];
    [self.delegate pushLoginView];    
}

- (void)viewDidUnload
{
    [self setTextServerAddress:nil];
    [self setDataDownLoader:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setServiceTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}



//确定按钮
- (IBAction)setCurrentOrg:(UIBarButtonItem *)sender {
    if (![self.textServerAddress.text isEqualToString:[[AppDelegate App] serverAddress]]) {
        NSString *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libraryDirectory = [paths objectAtIndex:0];
        NSString *plistFileName = @"Settings.plist";
        NSString *plistPath = [libraryDirectory stringByAppendingPathComponent:plistFileName];
        NSDictionary *serverSettingsDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: self.textServerAddress.text, [AppDelegate App].fileAddress, nil]
                                                                       forKeys:[NSArray arrayWithObjects: @"server address", @"file address", nil]];
        NSPropertyListFormat format;
        NSString *errorDesc = nil;
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSMutableDictionary *plistDict = [[NSPropertyListSerialization
                                           propertyListFromData:plistXML
                                           mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                           format:&format
                                           errorDescription:&errorDesc] mutableCopy];
        [plistDict setObject:serverSettingsDict forKey:@"Server Settings"];
        NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
                                                                       format:NSPropertyListXMLFormat_v1_0
                                                             errorDescription:&error];
        
        if ([[NSFileManager defaultManager] isWritableFileAtPath:plistPath]) {
            if(plistData) {
                [plistData writeToFile:plistPath atomically:YES];
            }
        }
        [AppDelegate App].serverAddress=self.textServerAddress.text;
    }
    [self.dataDownLoader startDownLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadFinished) name:DOWNLOADFINISHNOTI object:nil];
}

- (void)downLoadFinished{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveService:(UIButton *)sender {
    
    NSLog(@"%@",self.serviceTextField.text);
}

- (IBAction)ServiceChoose:(UITextField *)sender {
    
    [self pickerPresentForIndex:0 fromRect:sender.frame];
}

//弹窗
-(void)pickerPresentForIndex:(NSInteger )pickerType fromRect:(CGRect)rect{
    if ([_pickerPopOver isPopoverVisible]) {
        [_pickerPopOver dismissPopoverAnimated:YES];
    } else {
        ServiceListViewController *pickerVC=[[ServiceListViewController alloc]init];
        self.pickerPopOver=[[UIPopoverController alloc] initWithContentViewController:pickerVC];
        
        pickerVC.delegate = self;
        
        if (pickerType == 0) {
            pickerVC.tableView.frame=CGRectMake(0, 0, 140, 176);
            self.pickerPopOver.popoverContentSize=CGSizeMake(140, 176);
        }
        [_pickerPopOver presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        pickerVC.pickerPopover=self.pickerPopOver;
    }
}

-(void)setServiceTextDelegate:(NSString *)aText{
    if (![self.serviceTextField.text isEqualToString:aText]) {
        self.serviceTextField.text=aText;
    }
    
    if ([self.serviceTextField.text isEqualToString:@"广云"]) {
        self.textServerAddress.text = @"http://219.131.172.162:81/irmsdatagy/";
    }else
    {
        self.textServerAddress.text = @"http://219.131.172.162:81/irmsdata/";
    }
}
@end
