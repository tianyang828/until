#import "LoginViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>

#import "ActivityViewController.h"
#import "Config.h"
#import "Functions.h"
#import "KeyboardUtil.h"
#import "OAuthGridView.h"
#import "TermsAndConditionsViewController.h"
#import "UserService.h"
#import "VerifyPhoneViewController.h"

@implementation LoginViewController {
	BOOL _complete;

	UITextField *_username;
	UITextField *_password;

	UIButton *_loginButton;
}

- (void)closeButtonHandler:(UIBarButtonItem *)sender {
	UIViewController *presentingViewController = [Functions topViewController:self.presentingViewController];

	[self dismissViewControllerAnimated:YES completion:^{
		if (_complete) {
			if (_referer) {
				if ([presentingViewController isMemberOfClass:[ActivityViewController class]]) {
					[(ActivityViewController *) presentingViewController loginSuccess];
				}
			}
		}

		[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
	}];
}

- (void)forgotButtonOnTouchUpInside:(UIButton *)sender {
	VerifyPhoneViewController *verifyPhoneViewController = [[VerifyPhoneViewController alloc] init];
	verifyPhoneViewController.type = 2;

	[self.navigationController pushViewController:verifyPhoneViewController animated:YES];
}

- (void)hideKeyboardButtonHandler:(UIBarButtonItem *)sender {
	[KeyboardUtil hide:@[_username, _password]];
}

- (void)keyboardDidShowNotification:(NSNotification *)sender {
	[KeyboardUtil didShow:sender items:@[_username, _password] viewController:self];
}

- (void)keyboardWillHideNotification:(NSNotification *)sender {
	[KeyboardUtil willHide:sender viewController:self];
}

- (void)loginButtonOnTouchUpInside:(UIButton *)sender {
	[self hideKeyboardButtonHandler:nil];

	NSString *username = _username.text;
	NSString *password = [OCFunctions md5String:[OCFunctions md5String:_password.text]];

	if ([username rangeOfString:@"^1\\d{10}$" options:NSRegularExpressionSearch].location == NSNotFound) {
		[Functions alert:@"请输入正确手机号" message:nil callback:^{
			[_username becomeFirstResponder];
		} container:self];

		return;
	}

	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	[UserService login:username password:password callback:^{
		_complete = YES;

		[self closeButtonHandler:nil];
	} viewController:self];
}

- (void)registerButtonOnTouchUpInside:(UIButton *)sender {
	[self.navigationController pushViewController:[[TermsAndConditionsViewController alloc] init] animated:YES];
}

- (void)textFieldTextDidChangeNotification:(NSNotification *)sender {
	BOOL valid = ![OCFunctions isEmpty:_username.text] && ![OCFunctions isEmpty:_password.text];
	_loginButton.enabled = valid;
}

#pragma mark <UITextFieldDelegate>

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[KeyboardUtil setActiveView:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[KeyboardUtil setActiveView:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == _password) {
		[self loginButtonOnTouchUpInside:nil];
	}

	return NO;
}

#pragma mark

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = COLOR_BG;

	//self.navigationItem.title = nil;


	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow4"] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonHandler:)];


	/**/
	UIToolbar *inputAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
	inputAccessoryView.tintColor = [UIColor grayColor];
	inputAccessoryView.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"keyboard"] style:UIBarButtonItemStylePlain target:self action:@selector(hideKeyboardButtonHandler:)]];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:nil];


	/**/
	UIImageView *header = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-bg"]];
	[self.view addSubview:header];

	header.translatesAutoresizingMaskIntoConstraints = NO;
	for (NSString *item in @[@"|[header]|", @"V:|[header]"]) {
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:item options:0 metrics:nil views:NSDictionaryOfVariableBindings(header)]];
	}
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:header attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:header attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:810 / 1242.f constant:0]];


	/**/
	UIView *fieldset = [[UIView alloc] init];
	[self.view addSubview:fieldset];

	fieldset.layer.borderColor = OCColorWithRGBA(128, 128, 128, 0.25).CGColor;
	fieldset.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
	fieldset.layer.cornerRadius = 12;

	fieldset.translatesAutoresizingMaskIntoConstraints = NO;
	for (NSString *item in @[@"|-48-[fieldset]-48-|"]) {
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:item options:0 metrics:nil views:NSDictionaryOfVariableBindings(fieldset)]];
	}
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:fieldset attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:header attribute:NSLayoutAttributeBottom multiplier:1 constant:!IPHONE4X ? 48 : 8]];

	UILabel *usernameLabel = [[UILabel alloc] init];
	[fieldset addSubview:usernameLabel];

	usernameLabel.text = @"帐号";
	usernameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	usernameLabel.textColor = [UIColor darkGrayColor];

	usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
	for (NSString *item in @[@"|-16-[usernameLabel(64)]", @"V:|-16-[usernameLabel]"]) {
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:item options:0 metrics:nil views:NSDictionaryOfVariableBindings(usernameLabel)]];
	}

	_username = [[UITextField alloc] init];
	[fieldset addSubview:_username];

	_username.delegate = self;

	_username.placeholder = @"请输入手机号码";
	_username.clearButtonMode = UITextFieldViewModeWhileEditing;
	_username.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	_username.inputAccessoryView = inputAccessoryView;
	_username.keyboardType = UIKeyboardTypeNumberPad;
	//_username.returnKeyType = UIReturnKeyNext;
	_username.textColor = [UIColor darkGrayColor];
	_username.tintColor = COLOR1;

	_username.translatesAutoresizingMaskIntoConstraints = NO;
	for (NSString *item in @[@"[usernameLabel]-[_username]-16-|"]) {
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:item options:0 metrics:nil views:NSDictionaryOfVariableBindings(usernameLabel, _username)]];
	}
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:_username attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:usernameLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

	UIView *fieldsetBorder = [[UIView alloc] init];
	[fieldset addSubview:fieldsetBorder];

	fieldsetBorder.alpha = 0.25;
	fieldsetBorder.backgroundColor = [UIColor grayColor];

	fieldsetBorder.translatesAutoresizingMaskIntoConstraints = NO;
	for (NSString *item in @[@"|[fieldsetBorder]|"]) {
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:item options:0 metrics:nil views:NSDictionaryOfVariableBindings(fieldsetBorder)]];
	}
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:fieldsetBorder attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:fieldset attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:fieldsetBorder attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1 / [UIScreen mainScreen].scale]];

	UILabel *passwordLabel = [[UILabel alloc] init];
	[fieldset addSubview:passwordLabel];

	passwordLabel.text = @"密码";
	passwordLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	passwordLabel.textColor = [UIColor darkGrayColor];

	passwordLabel.translatesAutoresizingMaskIntoConstraints = NO;
	for (NSString *item in @[@"|-16-[passwordLabel(64)]", @"V:[usernameLabel]-24-[passwordLabel]-16-|"]) {
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:item options:0 metrics:nil views:NSDictionaryOfVariableBindings(usernameLabel, passwordLabel)]];
	}

	_password = [[UITextField alloc] init];
	[fieldset addSubview:_password];

	_password.delegate = self;

	_password.placeholder = @"请输入密码";
	_password.clearButtonMode = UITextFieldViewModeWhileEditing;
	_password.enablesReturnKeyAutomatically = YES;
	_password.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	_password.inputAccessoryView = inputAccessoryView;
	_password.returnKeyType = UIReturnKeyGo;
	_password.secureTextEntry = YES;
	_password.textColor = [UIColor darkGrayColor];
	_password.tintColor = COLOR1;

	_password.translatesAutoresizingMaskIntoConstraints = NO;
	for (NSString *item in @[@"[passwordLabel]-[_password]-16-|"]) {
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:item options:0 metrics:nil views:NSDictionaryOfVariableBindings(passwordLabel, _password)]];
	}
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:_password attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:passwordLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];


	/**/
	_loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.view addSubview:_loginButton];

	_loginButton.enabled = NO;

	[_loginButton setTitle:@"登录" forState:UIControlStateNormal];
	[_loginButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
	[_loginButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];

	_loginButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

	_loginButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:_loginButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:_loginButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:fieldset attribute:NSLayoutAttributeBottom multiplier:1 constant:!IPHONE4X ? 16 : 0]];

	[_loginButton addTarget:self action:@selector(loginButtonOnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];


	/**/
	UIView *registerAndForgotWrapper = [[UIView alloc] init];
	[self.view addSubview:registerAndForgotWrapper];

	registerAndForgotWrapper.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:registerAndForgotWrapper attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:registerAndForgotWrapper attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_loginButton attribute:NSLayoutAttributeBottom multiplier:1 constant:!IPHONE4X ? 8 : 0]];

	UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[registerAndForgotWrapper addSubview:registerButton];

	[registerButton setTitle:@"立即注册" forState:UIControlStateNormal];
	[registerButton setTitleColor:COLOR_LINK forState:UIControlStateNormal];

	registerButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];

	registerButton.translatesAutoresizingMaskIntoConstraints = NO;
	for (NSString *item in @[@"|[registerButton]", @"V:|[registerButton]|"]) {
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:item options:0 metrics:nil views:NSDictionaryOfVariableBindings(registerButton)]];
	}

	[registerButton addTarget:self action:@selector(registerButtonOnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];

	UIView *verticalBar = [[UIView alloc] init];
	[registerAndForgotWrapper addSubview:verticalBar];

	verticalBar.backgroundColor = [UIColor grayColor];

	verticalBar.translatesAutoresizingMaskIntoConstraints = NO;
	for (NSString *item in @[@"[registerButton]-[verticalBar]"]) {
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:item options:0 metrics:nil views:NSDictionaryOfVariableBindings(registerButton, verticalBar)]];
	}
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:verticalBar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:registerAndForgotWrapper attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:verticalBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote].lineHeight * 0.8]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:verticalBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1]];

	UIButton *forgotButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[registerAndForgotWrapper addSubview:forgotButton];

	[forgotButton setTitle:@"忘记密码" forState:UIControlStateNormal];
	[forgotButton setTitleColor:COLOR_LINK forState:UIControlStateNormal];

	forgotButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];

	forgotButton.translatesAutoresizingMaskIntoConstraints = NO;
	for (NSString *item in @[@"[verticalBar]-[forgotButton]|", @"V:|[forgotButton]|"]) {
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:item options:0 metrics:nil views:NSDictionaryOfVariableBindings(verticalBar, forgotButton)]];
	}

	[forgotButton addTarget:self action:@selector(forgotButtonOnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];


	/**/
	OAuthGridView *oAuthGridView = [[OAuthGridView alloc] initWithItems:nil numberOfItemsInRow:3 rows:1 viewController:self];
	[self.view addSubview:oAuthGridView];

	oAuthGridView.textColor = [UIColor grayColor];

	oAuthGridView.translatesAutoresizingMaskIntoConstraints = NO;
	for (NSString *item in @[@"|[oAuthGridView]|", @"V:[oAuthGridView]|"]) {
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:item options:0 metrics:nil views:NSDictionaryOfVariableBindings(oAuthGridView)]];
	}

	UILabel *oAuthLoginTitle = [[UILabel alloc] init];
	[self.view addSubview:oAuthLoginTitle];

	oAuthLoginTitle.text = @"其他方式登录";
	oAuthLoginTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
	oAuthLoginTitle.textColor = [UIColor grayColor];

	oAuthLoginTitle.translatesAutoresizingMaskIntoConstraints = NO;
	for (NSString *item in @[@"V:[oAuthLoginTitle]-[oAuthGridView]"]) {
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:item options:0 metrics:nil views:NSDictionaryOfVariableBindings(oAuthGridView, oAuthLoginTitle)]];
	}
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:oAuthLoginTitle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

	UIView *oAuthLoginTitleBorderLeft = [[UIView alloc] init];
	[self.view addSubview:oAuthLoginTitleBorderLeft];

	oAuthLoginTitleBorderLeft.alpha = 0.25;
	oAuthLoginTitleBorderLeft.backgroundColor = [UIColor grayColor];

	oAuthLoginTitleBorderLeft.translatesAutoresizingMaskIntoConstraints = NO;
	for (NSString *item in @[@"|[oAuthLoginTitleBorderLeft]-[oAuthLoginTitle]"]) {
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:item options:0 metrics:nil views:NSDictionaryOfVariableBindings(oAuthLoginTitle, oAuthLoginTitleBorderLeft)]];
	}
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:oAuthLoginTitleBorderLeft attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:oAuthLoginTitle attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:oAuthLoginTitleBorderLeft attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1 / [UIScreen mainScreen].scale]];

	UIView *oAuthLoginTitleBorderRight = [[UIView alloc] init];
	[self.view addSubview:oAuthLoginTitleBorderRight];

	oAuthLoginTitleBorderRight.alpha = 0.25;
	oAuthLoginTitleBorderRight.backgroundColor = [UIColor grayColor];

	oAuthLoginTitleBorderRight.translatesAutoresizingMaskIntoConstraints = NO;
	for (NSString *item in @[@"[oAuthLoginTitle]-[oAuthLoginTitleBorderRight]|"]) {
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:item options:0 metrics:nil views:NSDictionaryOfVariableBindings(oAuthLoginTitle, oAuthLoginTitleBorderRight)]];
	}
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:oAuthLoginTitleBorderRight attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:oAuthLoginTitle attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:oAuthLoginTitleBorderRight attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1 / [UIScreen mainScreen].scale]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
	[self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];

	NSLog(@"%@: didReceiveMemoryWarning", [self class]);
}

@end
