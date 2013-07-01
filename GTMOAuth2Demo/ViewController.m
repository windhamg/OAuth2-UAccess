//
//  ViewController.m
//  GTMOAuth2Demo
//
//  Created by Gary on 6/12/13.
//  Copyright (c) 2013 Gary Windham. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (GTMOAuth2Authentication * ) authForUA
{
    //This URL is defined by the individual 3rd party APIs, be sure to read their documentation
    NSString * url_string = @"https://ws.uits.arizona.edu/php-oauth/token.php";
    NSURL * tokenURL = [NSURL URLWithString:url_string];
    // We'll make up an arbitrary redirectURI.  The controller will watch for
    // the server to redirect the web view to this URI, but this URI will not be
    // loaded, so it need not be for any actual web page. This needs to match the URI set as the
    // redirect URI when configuring the app with Instagram.
    NSString * redirectURI = @"http://bogus-redirect-for-testiosnativeapp";
    GTMOAuth2Authentication * auth;
    auth = [GTMOAuth2Authentication authenticationWithServiceProvider:@"UA"
                                                             tokenURL:tokenURL
                                                          redirectURI:redirectURI
                                                             clientID:@"nativeiosapp"
                                                         clientSecret:@"DyNvuecxpDNoOb9p4Z9p"];
    auth.scope = @"schedule-of-classes";
    return auth;
}

- (void)signInToUA
{
    GTMOAuth2Authentication * auth = [self authForUA];
    NSString* auth_string = @"https://ws.uits.arizona.edu/php-oauth/authorize.php";
    NSURL * authURL = [NSURL URLWithString:auth_string];
    // Display the authentication view
    GTMOAuth2ViewControllerTouch * viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithAuthentication:auth
                                                                 authorizationURL:authURL
                                                                 keychainItemName:nil
                                                                         delegate:self
                                                                 finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch * )viewController
      finishedWithAuth:(GTMOAuth2Authentication * )auth
                 error:(NSError * )error
{
    NSLog(@"Inside finishedSelector");
    [self.navigationController popToViewController:self animated:NO];
    if (error != nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error Authorizing with UA"
                                                         message:[error localizedDescription]
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    } else {
        //Authorization was successful - get location information
        NSString *urlStr = @"https://ws.uits.arizona.edu/uaccess-sa-ical/index.php";
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [auth authorizeRequest:request
                  completionHandler:^(NSError *error) {
                      NSString *output = nil;
                      if (error) {
                          output = [error description];
                      } else {
                          // Synchronous fetches like this are a really bad idea in Cocoa applications
                          //
                          // For a very easy async alternative, we could use GTMHTTPFetcher
                          NSURLResponse *response = nil;
                          NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                               returningResponse:&response
                                                                           error:&error];
                          if (data) {
                              // API fetch succeeded
                              output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                          } else {
                              // fetch failed
                              output = [error description];
                          }
                      }
                      
                      [self displayAlertWithMessage:output];
                  }];
    }
}

- (void)displayAlertWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GTMOAuth2Demo"
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [alert show];
}


- (IBAction)loginButtonTapped:(id)sender
{
    NSLog(@"Calling signInToUA");
    [self signInToUA];
}


@end
