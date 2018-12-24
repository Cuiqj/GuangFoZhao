//
//  AtonementNoticePrintViewController.m
//  GDRMMobile
//
//  Created by yu hongwu on 12-11-29.
//
//

#import "AtonementNoticePrintViewController.h"
#import "AtonementNotice.h"
#import "CaseDeformation.h"
#import "CaseProveInfo.h"
#import "Citizen.h"
#import "CaseInfo.h"
#import "RoadSegment.h"
#import "OrgInfo.h"
#import "UserInfo.h"
#import "NSNumber+NumberConvert.h"
#import "Systype.h"
#import "MatchLaw.h"
#import "MatchLawDetails.h"
#import "LawItems.h"
#import "LawbreakingAction.h"
#import "Laws.h"
#import "FileCode.h"
#import "DateSelectController.h"

static NSString * xmlName = @"AtonementNoticeTable";

@interface AtonementNoticePrintViewController ()
@property (nonatomic,retain) AtonementNotice *notice;
@property (nonatomic,retain) UIPopoverController *pickerPopover;
- (void)generateDefaultsForNotice:(AtonementNotice *)notice;
@end

@implementation AtonementNoticePrintViewController
@synthesize labelCaseCode = _labelCaseCode;
@synthesize textParty = _textParty;
@synthesize textPartyAddress = _textPartyAddress;
@synthesize textCaseReason = _textCaseReason;
@synthesize textOrg = _textOrg;
@synthesize textViewCaseDesc = _textViewCaseDesc;
@synthesize textWitness = _textWitness;
@synthesize textViewPayReason = _textViewPayReason;
@synthesize textPayMode = _textPayMode;
@synthesize textCheckOrg = _textCheckOrg;
@synthesize labelDateSend = _labelDateSend;
@synthesize textBankName = _textBankName;
@synthesize caseID = _caseID;
@synthesize notice = _notice;
@synthesize pickerPopover=_pickerPopover;

- (void)viewDidLoad
{
    [super setCaseID:self.caseID];
    [self LoadPaperSettings:xmlName];
    CGRect viewFrame = CGRectMake(0.0, 0.0, VIEW_FRAME_WIDTH, VIEW_FRAME_HEIGHT);
    self.view.frame = viewFrame;
    [super setCaseID:self.caseID];
    NSString * strtemp = [[AppDelegate App] serverAddress];
    
//    if ([strtemp isEqualToString:@"http://219.131.172.164:81/irmsdatagy/"]) {
//        xmlName = @"GYAtonementNoticeTable";
//    }
    [self LoadPaperSettings:xmlName];
    /*modify by lxm 不能实时更新*/
     if (![self.caseID isEmpty]) {
         NSArray *noticeArray = [AtonementNotice AtonementNoticesForCase:self.caseID];
         if (noticeArray.count>0) {
             self.notice = [noticeArray objectAtIndex:0];
         } else {
             self.notice = [AtonementNotice newDataObjectWithEntityName:@"AtonementNotice"];
         }
         if (!self.notice.caseinfo_id || [self.notice.caseinfo_id isEmpty]) {
             self.notice.caseinfo_id = self.caseID;
             [self generateDefaultsForNotice:self.notice];
         }
        [self loadPageInfo];
     }
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setLabelCaseCode:nil];
    [self setTextParty:nil];
    [self setTextPartyAddress:nil];
    [self setTextCaseReason:nil];
    [self setTextOrg:nil];
    [self setTextViewCaseDesc:nil];
    [self setTextWitness:nil];
    [self setTextViewPayReason:nil];
    [self setTextPayMode:nil];
    [self setTextCheckOrg:nil];
    [self setLabelDateSend:nil];
    [self setNotice:nil];
	[self setTextBankName:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)pageSaveInfo
{
    [self savePageInfo];
}

- (void)loadPageInfo{
    CaseInfo *caseInfo = [CaseInfo caseInfoForID:self.caseID];
    self.labelCaseCode.text = [[NSString alloc] initWithFormat:@"(%@)年%@交赔字第%@号",caseInfo.case_mark2, [FileCode fileCodeWithPredicateFormat:@"赔补偿案件编号"].organization_code, caseInfo.full_case_mark3];
    Citizen *citizen = [Citizen citizenForCitizenName:self.notice.citizen_name nexus:@"当事人" case:self.caseID];
    CaseProveInfo *proveInfo = [CaseProveInfo proveInfoForCase:self.caseID];
    self.textParty.text = citizen.party;
    self.textPartyAddress.text = citizen.address;
    self.textCaseReason.text = [NSString stringWithFormat:@"%@%@因交通事故%@", citizen.automobile_number, citizen.automobile_pattern, proveInfo.case_short_desc];
    self.textOrg.text = self.notice.organization_id;
    self.textViewCaseDesc.text = self.notice.case_desc;
    
    //案件勘验详情
    self.textWitness.text = self.notice.witness;
    self.textViewPayReason.text = self.notice.pay_reason;
    
    NSArray *temp=[Citizen allCitizenNameForCase:self.caseID];
    NSArray *citizenList=[[temp valueForKey:@"automobile_number"] mutableCopy];
    
    NSArray *deformations = [CaseDeformation deformationsForCase:self.caseID forCitizen:[citizenList objectAtIndex:0]];
    double summary=[[deformations valueForKeyPath:@"@sum.total_price.doubleValue"] doubleValue];
    NSNumber *sumNum = @(summary);
    NSString *numString = [sumNum numberConvertToChineseCapitalNumberString];
    self.textPayMode.text = [NSString stringWithFormat:@"路产损失费人民币%@(￥%.2f)",numString,summary];
    
    self.textBankName.text = [self.notice bank_name];
    self.textCheckOrg.text = self.notice.check_organization;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy     年      MM      月      dd      日"];
    self.labelDateSend.text = [dateFormatter stringFromDate:self.notice.date_send];
    self.textDateSend.text=[dateFormatter stringFromDate:self.notice.date_send];
    [self.labelDateSend setHidden:YES];
    
}

- (void)generateDefaultAndLoad
{
    [self generateDefaultsForNotice:self.notice];
    [self loadPageInfo];
}

- (void)savePageInfo{
    CaseProveInfo *proveInfo = [CaseProveInfo proveInfoForCase:self.caseID];
    proveInfo.case_long_desc = self.textCaseReason.text;
    self.notice.organization_id = self.textOrg.text;
    self.notice.case_desc = self.textViewCaseDesc.text;
    self.notice.pay_mode = self.textPayMode.text;
    self.notice.pay_reason = self.textViewPayReason.text;
    self.notice.check_organization = self.textCheckOrg.text;
    self.notice.witness = self.textWitness.text;
    [[AppDelegate App] saveContext];
}

- (void)generateDefaultsForNotice:(AtonementNotice *)notice  {
    CaseProveInfo *proveInfo = [CaseProveInfo proveInfoForCase:self.caseID];

    NSDateFormatter *codeFormatter = [[NSDateFormatter alloc] init];
    [codeFormatter setDateFormat:@"yyyyMM'0'dd"];
    [codeFormatter setLocale:[NSLocale currentLocale]];
    notice.code = [codeFormatter stringFromDate:[NSDate date]];

      
    notice.case_desc = [CaseProveInfo generateEventDescForNotice:self.caseID];
    notice.case_desc = [NSString stringWithFormat:@"%@%@",notice.case_desc,@"详细见《损坏公路设施索赔清单》"];
    //notice.citizen_name = proveInfo.citizen_name;
    Citizen *citizen=[Citizen citizenByCaseID:self.caseID andNexus:@"当事人"];
    notice.citizen_name=citizen.automobile_number;
    notice.witness = @"现场勘验笔录、询问笔录、现场勘查图、现场照片";
    notice.check_organization = [[Systype typeValueForCodeName:@"复核单位"] objectAtIndex:0];
    NSString *currentUserID=[[NSUserDefaults standardUserDefaults] stringForKey:USERKEY];
    notice.organization_id = [[OrgInfo orgInfoForOrgID:[UserInfo userInfoForUserID:currentUserID].organization_id] valueForKey:@"orgname"];
    
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MatchLaw" ofType:@"plist"];
    NSDictionary *matchLaws = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *payReason = @"";
    if (matchLaws) {
        NSString *breakStr = @"";
        NSString *matchStr = @"";
        NSString *payStr = @"";
        
        
        NSMutableArray *breakArray = [[NSMutableArray alloc]init];
        NSMutableArray *matchArray = [[NSMutableArray alloc]init];
        NSMutableArray *payArray = [[NSMutableArray alloc]init];
        for(NSString *case_desc_id in [proveInfo.case_desc_id componentsSeparatedByString:@"#"]){
            NSDictionary *matchInfo = [[matchLaws objectForKey:@"case_desc_match_law"] objectForKey:case_desc_id];
            if (matchInfo) {
                if ([matchInfo objectForKey:@"breakLaw"]) {
                    NSArray *tempArray = (NSArray *)[matchInfo objectForKey:@"breakLaw"] ;
                    if([breakArray count] > 0){
                        for(NSString *temp in tempArray){
                            BOOL flag = FALSE;
                            for(NSString *temp2 in breakArray){
                                if([temp isEqual:temp2]){
                                    flag = TRUE;
                                }
                            }
                            if(!flag){
                                [breakArray addObject:temp];
                            }
                        }
                    }else{
                        breakArray = [[NSMutableArray alloc]initWithArray:tempArray];
                    }
                    
                }
                if ([matchInfo objectForKey:@"matchLaw"]) {
                    NSArray *tempArray = (NSArray *)[matchInfo objectForKey:@"matchLaw"] ;
                    if([matchArray count] > 0){
                        for(NSString *temp in tempArray){
                            BOOL flag = FALSE;
                            for(NSString *temp2 in matchArray){
                                if([temp isEqual:temp2]){
                                    flag = TRUE;
                                }
                            }
                            if(!flag){
                                [matchArray addObject:temp];
                            }
                        }
                    }else{
                        matchArray = [[NSMutableArray alloc]initWithArray:tempArray];
                    }
                }
                if ([matchInfo objectForKey:@"payLaw"]) {
                    NSArray *tempArray = (NSArray *)[matchInfo objectForKey:@"payLaw"] ;
                    if([payArray count] > 0){
                        for(NSString *temp in tempArray){
                            BOOL flag = FALSE;
                            for(NSString *temp2 in payArray){
                                if([temp isEqual:temp2]){
                                    flag = TRUE;
                                }
                            }
                            if(!flag){
                                [payArray addObject:temp];
                            }
                        }
                    }else{
                        payArray = [[NSMutableArray alloc]initWithArray:tempArray];
                    }
                }
            }
        }
        
        //由于目前违反的法律只有两条，所以这里就不想进行太复杂的处理的
        if([breakArray count] >= 2){
            breakStr = BREAK_TWO_RULES;
        }else{
            breakStr = [breakStr stringByAppendingString:[breakArray componentsJoinedByString:@"、"]];
        }
        
        
        matchStr = [matchStr stringByAppendingString:[matchArray componentsJoinedByString:@"、"]];
        payStr = [payStr stringByAppendingString:[payArray componentsJoinedByString:@"、"]];


        //payReason = [NSString stringWithFormat:@"%@事实清楚，其行为违反了%@规定，根据%@、并依照%@的规定，当事人应当承担民事责任，赔偿路产损失。", proveInfo.case_short_desc, breakStr, matchStr, payStr];
        payReason = [NSString stringWithFormat:@"%@规定，根据%@、并依照%@",  breakStr, matchStr, payStr];
    }
    notice.pay_reason = payReason;
    NSArray *deformations = [CaseDeformation deformationsForCase:self.caseID forCitizen:notice.citizen_name];
    double summary=[[deformations valueForKeyPath:@"@sum.total_price.doubleValue"] doubleValue];
    NSNumber *sumNum = @(summary);
    NSString *numString = [sumNum numberConvertToChineseCapitalNumberString];
    notice.pay_mode = [NSString stringWithFormat:@"路产损失费人民币%@（￥%.2f）",numString,summary];
    notice.date_send = [NSDate date];
    [[AppDelegate App] saveContext];
}

/*test by lxm 无效*/
-(NSURL *)toFullPDFWithTable:(NSString *)filePath{
    [self savePageInfo];
    if (![filePath isEmpty]) {
        CGRect pdfRect=CGRectMake(0.0, 0.0, paperWidth, paperHeight);
        UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
        UIGraphicsBeginPDFPageWithInfo(pdfRect, nil);
        [self drawStaticTable:xmlName];
        [self drawDateTable:xmlName withDataModel:self.notice];
        
        //add by lxm 2013.05.08
        CaseInfo *caseInfo = [CaseInfo caseInfoForID:self.caseID];
        self.labelCaseCode.text = [[NSString alloc] initWithFormat:@"(%@)年%@高交赔字第%@号",caseInfo.case_mark2, [[AppDelegate App].projectDictionary objectForKey:@"cityname"], caseInfo.full_case_mark3];
        Citizen *citizen = [Citizen citizenForCitizenName:self.notice.citizen_name nexus:@"当事人" case:self.caseID];
        [self drawDateTable:xmlName withDataModel:citizen];
        
        CaseProveInfo *proveInfo = [CaseProveInfo proveInfoForCase:self.caseID];
        [self drawDateTable:xmlName withDataModel:proveInfo];
        
        
        UIGraphicsEndPDFContext();
        return [NSURL fileURLWithPath:filePath];
    } else {
        return nil;
    }
}

-(NSURL *)toFullPDFWithPath:(NSString *)filePath{
    [self savePageInfo];
    if (![filePath isEmpty]) {
        CGRect pdfRect=CGRectMake(0.0, 0.0, paperWidth, paperHeight);
        UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
        UIGraphicsBeginPDFPageWithInfo(pdfRect, nil);
        [self drawStaticTable1:xmlName];
        
        self.notice.case_desc = [self.notice.case_desc substringFromIndex:1];
        [self drawDateTable:xmlName withDataModel:self.notice];
        
        //add by lxm 2013.05.08
        CaseInfo *caseInfo = [CaseInfo caseInfoForID:self.caseID];
        [self drawDateTable:xmlName withDataModel:caseInfo];

        Citizen *citizen = [Citizen citizenForCitizenName:self.notice.citizen_name nexus:@"当事人" case:self.caseID];
        [self drawDateTable:xmlName withDataModel:citizen];
        
        CaseProveInfo *proveInfo = [CaseProveInfo proveInfoForCase:self.caseID];
        [self drawDateTable:xmlName withDataModel:proveInfo];
        
        UIGraphicsEndPDFContext();
        //self.notice.case_desc = [NSString stringWithFormat:@"于%@",self.notice.case_desc ];
        return [NSURL fileURLWithPath:filePath];
    } else {
        return nil;
    }
}

-(NSURL *)toFormedPDFWithPath:(NSString *)filePath{
    [self savePageInfo];
    if (![filePath isEmpty]) {
        CGRect pdfRect=CGRectMake(0.0, 0.0, paperWidth, paperHeight);
        NSString *formatFilePath = [NSString stringWithFormat:@"%@.format.pdf", filePath];
        UIGraphicsBeginPDFContextToFile(formatFilePath, CGRectZero, nil);
        UIGraphicsBeginPDFPageWithInfo(pdfRect, nil);
        [self drawDateTable:xmlName withDataModel:self.notice];
        
        //add by lxm 2013.05.08
        CaseInfo *caseInfo = [CaseInfo caseInfoForID:self.caseID];
        [self drawDateTable:xmlName withDataModel:caseInfo];
        
        Citizen *citizen = [Citizen citizenForCitizenName:self.notice.citizen_name nexus:@"当事人" case:self.caseID];
        [self drawDateTable:xmlName withDataModel:citizen];
        
        CaseProveInfo *proveInfo = [CaseProveInfo proveInfoForCase:self.caseID];
        [self drawDateTable:xmlName withDataModel:proveInfo];
        
        UIGraphicsEndPDFContext();
        return [NSURL fileURLWithPath:formatFilePath];
    } else {
        return nil;
    }
}


- (IBAction)btnSelectTime:(UITextField *)sender {
    if ([self.pickerPopover isPopoverVisible]) {
        [self.pickerPopover dismissPopoverAnimated:YES];
    } else {
        DateSelectController *datePicker=[self.storyboard instantiateViewControllerWithIdentifier:@"datePicker"];
        datePicker.delegate=self;
        datePicker.pickerType=1;
        datePicker.pastDate=self.notice.date_send;
        //[datePicker showdate:self.notice.date_send];
        self.pickerPopover=[[UIPopoverController alloc] initWithContentViewController:datePicker];
        [self.pickerPopover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        datePicker.dateselectPopover=self.pickerPopover;
    }
}
-(void)setDate:(NSString *)date{
  self.textDateSend.text=date;
}
-(void)setPastDate:(NSDate *)date withTag:(int)tag{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy     年      MM      月      dd      日"];
    self.textDateSend.text=[dateFormatter stringFromDate:date];
    self.notice.date_send=date;

}
@end
