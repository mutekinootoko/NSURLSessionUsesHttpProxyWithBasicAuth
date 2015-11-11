//
//  ViewController.m
//  NSURLSessionWithProxy
//
//  Created by Marku L. on 2015/11/12.
//  Copyright © 2015年 Hao-Yu, Marku, Lee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextField *proxyIpTextField;
@property (strong, nonatomic) IBOutlet UITextField *proxyPortTextField;
@property (strong, nonatomic) IBOutlet UITextField *proxyAuthUserNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *proxyAuthPasswordTextField;
@property (strong, nonatomic) IBOutlet UIButton *loadImageFromProxyButton;
@property (strong, nonatomic) IBOutlet UIWebView *loadWebView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.proxyIpTextField.delegate = self;
    self.proxyPortTextField.delegate = self;
    self.proxyAuthUserNameTextField.delegate = self;
    self.proxyAuthPasswordTextField.delegate = self;
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loadSomething:(UIButton *)sender {
    
    /*  THIS SETTING (FROM APPLE DEVELOPER DOC) DOES NOT WORK
    NSDictionary* proxyProperties = @{
                                      (NSString *)kCFProxyHostNameKey  : self.proxyIpTextField.text,
                                      (NSString *)kCFProxyPortNumberKey  : [NSNumber numberWithInteger: self.proxyPortTextField.text.integerValue],
                                      (NSString*) kCFProxyUsernameKey : self.proxyAuthUserNameTextField.text,
                                      (NSString*) kCFProxyPasswordKey : self.proxyAuthPasswordTextField.text,
                                      (NSString*) kCFProxyTypeKey : (NSString*) kCFProxyTypeHTTP
                                      
                                      };
     */
    
    // http://stackoverflow.com/questions/28101582/how-to-programmatically-add-a-proxy-to-an-nsurlsession
    NSDictionary* proxyProperties = @{
                                      @"HTTPEnable"  : [NSNumber numberWithInt:1],
                                      (NSString *)kCFStreamPropertyHTTPProxyHost  : self.proxyIpTextField.text,
                                      (NSString *)kCFStreamPropertyHTTPProxyPort  : [NSNumber numberWithInteger: self.proxyPortTextField.text.integerValue],
                                      
                                      @"HTTPSEnable" : [NSNumber numberWithInt:1],
                                      (NSString *)kCFStreamPropertyHTTPSProxyHost : self.proxyIpTextField.text,
                                      (NSString *)kCFStreamPropertyHTTPSProxyPort : [NSNumber numberWithInteger: self.proxyPortTextField.text.integerValue]
                                      };
    
    // basic auth
    NSString *userPasswordString = [NSString stringWithFormat:@"%@:%@", self.proxyAuthUserNameTextField.text, self.proxyAuthPasswordTextField.text];
    NSData * userPasswordData = [userPasswordString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodedCredential = [userPasswordData base64EncodedStringWithOptions:0];
    NSString *authString = [NSString stringWithFormat:@"Basic %@", base64EncodedCredential];
    
    NSURLSessionConfiguration* proxyConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    proxyConfig.connectionProxyDictionary = proxyProperties;
    proxyConfig.HTTPAdditionalHeaders = @{@"Proxy-Authorization" : authString};
    
    NSURLSession* urlsession = [NSURLSession sessionWithConfiguration:proxyConfig];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mylocation.org/"]];
    NSURLSessionDataTask* task = [urlsession dataTaskWithRequest:request
                                               completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                               
                                                   [self.loadWebView loadData:data
                                                                     MIMEType:@"text/html"
                                                             textEncodingName:@"utf-8"
                                                                      baseURL:[NSURL URLWithString:@"http://mylocation.org/"]];
                                                   
                                               }];
    [task resume];

    
    
}



#pragma mark - uitextfielddelegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    self.loadImageFromProxyButton.enabled = (self.proxyIpTextField.text.length > 0
                                             &&
                                             self.proxyPortTextField.text.length > 0
                                             &&
                                             self.proxyAuthUserNameTextField.text.length > 0
                                             &&
                                             self.proxyAuthPasswordTextField.text.length > 0);
    
    
    return  YES;
}

@end
