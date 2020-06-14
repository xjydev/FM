//
//  ContactViewController.m
//  QRcreate
//
//  Created by xiaodev on Aug/31/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//MECARD:FN:行;ORG:多彩;ADR:北京;TEL:1888888888;TITLE:个;

#import "ContactViewController.h"
//#import <AddressBook/AddressBook.h> 
//#import <AddressBookUI/AddressBookUI.h>
#import <ContactsUI/ContactsUI.h>
#import <ContactsUI/CNContactViewController.h>
#import <ContactsUI/CNContactPickerViewController.h>
#import "UIColor+Hex.h"
#import "XTools.h"
@interface ContactViewController ()<UITableViewDelegate,UITableViewDataSource,CNContactViewControllerDelegate,CNContactPickerDelegate>
{
    NSArray   *_contactArray;
    __weak IBOutlet UILabel *familyLabel;
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UITableView *_mainTableView;
    NSMutableDictionary *_mainDict;
    
}
@end

@implementation ContactViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
}
- (void)viewDidLoad {
    [super viewDidLoad];
     self.title = @"联系人";
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backBarButtonAction)];
    self.navigationItem.leftBarButtonItem = leftItem;
    _mainDict = [NSMutableDictionary dictionaryWithCapacity:0];
    _contactArray = @[@"电话：",@"地址：",@"公司:",@"邮箱:"];
   
//    self.contactStr = @"MECARD:FN:行1;ORG:多彩;ADR:北京;TEL:1888888888;TITLE:个;EM:33@163.com";
    NSString *subStr = [self.contactStr substringFromIndex:7];
    NSLog(@"sub == %@",subStr);
    NSArray *array = [subStr componentsSeparatedByString:@";"];
    for (NSString * cs in array) {
        NSArray *arr = [cs componentsSeparatedByString:@":"];
        if (arr.count == 2) {
            if (arr.firstObject&&arr.lastObject) {
                [_mainDict setObject:arr.lastObject forKey:arr.firstObject];
            }
        }
    }
    familyLabel.text = [NSString stringWithFormat:@"姓名：%@",_mainDict[@"FN"]];
    _nameLabel.text = [NSString stringWithFormat:@"职位：%@",_mainDict[@"TITLE"]];
    NSLog(@"==%@",_mainDict);
//    if ([XTOOLS showAdShow]) {
//        UIView *adview = [XTOOLS bannerAdViewRootViewController:self];
//        adview.center = CGPointMake(kScreen_Width/2, kScreen_Height-25);
//        [self.view addSubview:adview];
//    }
}
- (void)backBarButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contactArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactcell" forIndexPath:indexPath];
    cell.textLabel.text = _contactArray[indexPath.row];
    switch (indexPath.row) {
        case 0:
        {
            cell.detailTextLabel.text =_mainDict[@"TEL"];
            cell.detailTextLabel.textColor= kMainCOLOR;
        }
            break;
        case 1:
        {
            cell.detailTextLabel.text =_mainDict[@"ADR"];
            cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        }
            break;
        case 2:
        {
            cell.detailTextLabel.text =_mainDict[@"ORG"];
            NSLog(@"%@==org==%@",cell.detailTextLabel.text,_mainDict[@"ORG"]);
            cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        }
            break;
        case 3:
        {
            cell.detailTextLabel.text =_mainDict[@"EM"];
            NSLog(@"%@==EM==%@",cell.detailTextLabel.text,_mainDict[@"EM"]);
            cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UIAlertController *alert = [UIAlertController  alertControllerWithTitle:@"电话联系" message:[NSString stringWithFormat:@"%@:%@",_mainDict[@"FN"],_mainDict[@"TEL"]] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"打电话" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",_mainDict[@"TEL"]]]];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:confirm];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
  
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveContactAction:(UIButton *)sender {
    if (IOSSystemVersion<9.0) {
        [self showNeedIos9];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"创建新联系人" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        //1.创建Contact对象，必须是可变的
        CNMutableContact *contact = [[CNMutableContact alloc] init];
        //2.为contact赋值，这块比较恶心，很混乱，setValue4Contact中会给出常用值的对应关系
        [self setValue4Contact:contact existContect:NO];
        //3.创建新建好友页面
        CNContactViewController *controller = [CNContactViewController viewControllerForNewContact:contact];
        //代理内容根据自己需要实现
        controller.delegate = self;
        //4.跳转
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:navigation animated:YES completion:^{
        }];

        
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"添加到现有联系人" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        //1.跳转到联系人选择页面，注意这里没有使用UINavigationController
        CNContactPickerViewController *controller = [[CNContactPickerViewController alloc] init];
        controller.delegate = self;
        [self presentViewController:controller animated:YES completion:^{
            
        }];
    }];
    
    
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    if (IsPad) {
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = sender.frame;
    }
    
    
    [self presentViewController:alert animated:YES completion:nil];

    
}
//2.实现点选的代理，其他代理方法根据自己需求实现
- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    [picker.navigationController popViewControllerAnimated:YES];
    
}
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
    [picker dismissViewControllerAnimated:YES completion:^{
        //3.copy一份可写的Contact对象，不要尝试alloc一类，mutableCopy独此一家
        CNMutableContact *c = [contact mutableCopy];
        //4.为contact赋值
        [self setValue4Contact:c existContect:YES];
        //5.跳转到新建联系人页面
        CNContactViewController *controller = [CNContactViewController viewControllerForNewContact:c];
        controller.delegate = self;
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:navigation animated:YES completion:^{
        }];
    }];
}
#pragma mark -- CNContactViewControllerDelegate
- (BOOL)contactViewController:(CNContactViewController *)viewController shouldPerformDefaultActionForContactProperty:(CNContactProperty *)property {
    
    return YES;
}
- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact {
    [viewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
//对应关系
//设置要保存的contact对象
- (void)setValue4Contact:(CNMutableContact *)contact existContect:(BOOL)exist{
    if (!exist) {
        //名字和头像
       contact.familyName = _mainDict[@"FN"];
    }
    else
    {
       contact.nickname = _mainDict[@"FN"]; 
    }
    contact.jobTitle = _mainDict[@"TITLE"];
    contact.phoneticOrganizationName =_mainDict[@"ORG"];
    //电话,每一个CNLabeledValue都是有讲究的，如何批评，可以在头文件里面查找，这里给出几个常用的，别的我也不愿意去研究
    if (_mainDict[@"TEL"]) {
        CNLabeledValue *phoneNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:_mainDict[@"TEL"]]];
        if (!exist) {
            contact.phoneNumbers = @[phoneNumber];
        }
        //现有联系人情况
        else{
            if ([contact.phoneNumbers count] >0) {
                NSMutableArray *phoneNumbers = [[NSMutableArray alloc] initWithArray:contact.phoneNumbers];
                [phoneNumbers addObject:phoneNumber];
                contact.phoneNumbers = phoneNumbers;
            }else{
                contact.phoneNumbers = @[phoneNumber];
            }
        }
  
    }
    
    //网址:CNLabeledValue *url = [CNLabeledValue labeledValueWithLabel:@"" value:@""];
    //邮箱:
    if (_mainDict[@"EM"]) {
        CNLabeledValue *mail = [CNLabeledValue labeledValueWithLabel:CNLabelWork value:_mainDict[@"EM"]];
        contact.emailAddresses = @[mail];
    }
   
    if (_mainDict[@"ADR"]) {
        CNMutablePostalAddress *address = [[CNMutablePostalAddress alloc] init];
        //    address.state = @"辽宁省";
        //    address.city = @"沈阳市";
        //    address.postalCode = @"111111";
        //外国人好像都不强调区的概念，所以和具体地址拼到一起
        address.street = _mainDict[@"ADR"];
        //生成的上面地址的CNLabeledValue，其中可以设置类型CNLabelWork等等
        CNLabeledValue *addressLabel = [CNLabeledValue labeledValueWithLabel:CNLabelWork value:address];
        if (!exist) {
            contact.postalAddresses = @[addressLabel];
        }else{
            if ([contact.postalAddresses count] >0) {
                NSMutableArray *addresses = [[NSMutableArray alloc] initWithArray:contact.postalAddresses];
                [addresses addObject:addressLabel];
                contact.postalAddresses = addresses;
            }else{
                contact.postalAddresses = @[addressLabel];
            }
        }
  
    }
    //特别说一个地址，PostalAddress对应的才是地址
}
- (void)showNeedIos9 {
    [XTOOLS showAlertTitle:@"系统不支持" message:@"需要iOS9.0及以上系统才支持添加到通讯录" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
        
    }];
}
@end
