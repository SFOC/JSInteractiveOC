//
//  ViewController.m
//  研究JS和原生交互
//
//  Created by fly on 2017/6/30.
//  Copyright © 2017年 MGG. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h> // 引入WebKit框架

#define KWidth [UIScreen mainScreen].bounds.size.width
#define KHeight [UIScreen mainScreen].bounds.size.height
#define KScreenSize [UIScreen mainScreen].bounds.size
/**
 *  WKScriptMessageHandler：JS消息处理代理
 */
@interface ViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView; ///< WKWebView

@property (nonatomic, strong) UIView *bottomView; // 原生的View
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 加载H5页面
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
    [self.view addSubview:self.bottomView];
}
#pragma mark ---WKScriptMessageHandler---
/**
 *   用户内容控制器接收到JS的消息所要进行的处理方法
     JS的消息回调处理
     // 回调的执行必须JS配合写下面的方法
     window.webkit.messageHandlers.jsCallOC.postMessage();
 */
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"整个消息是：%@",message);
    NSLog(@"方法名:%@", message.name);
    NSLog(@"参数:%@", message.body);
    self.bottomView.hidden = self.bottomView.hidden?NO:YES;
}
#pragma mark ---WKNavigationDelegate代理---
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
   
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    
}
// 接收到服务器跳转请求之后再执行
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    // 允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
}
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // 允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark ---WKUIDelegate---
//1.创建一个新的WebVeiw
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    return nil;
}
//2.WebVeiw关闭（9.0中的新方法）
- (void)webViewDidClose:(WKWebView *)webView {
    
}
//3.显示一个JS的Alert（与JS交互）  当JS中有弹出框警示框的时候调用
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"%s",__FUNCTION__);
    // 确定按钮
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    // alert弹出框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
//4.弹出一个输入框（与JS交互的）
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    NSLog(@"%s",__FUNCTION__);
    // alert弹出框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:nil preferredStyle:UIAlertControllerStyleAlert];
    // 输入框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = defaultText;
    }];
    // 确定按钮
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 返回用户输入的信息
        UITextField *textField = alertController.textFields.firstObject;
        completionHandler(textField.text);
    }]];
    // 显示
    [self presentViewController:alertController animated:YES completion:nil];
}
//5.显示一个确认框（JS的）
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    // 按钮
    UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // 返回用户选择的信息
        completionHandler(NO);
    }];
    UIAlertAction *alertActionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    // alert弹出框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:alertActionCancel];
    [alertController addAction:alertActionOK];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark ---原生按钮回调---
- (void)btnAction:(UIButton *)sender {
    [_webView evaluateJavaScript:@"ocCallJS('哈哈')" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
        NSLog(@"原生调用JS");
    }];
}


#pragma mark ---懒加载---
- (WKWebView *)webView {
    if (_webView == nil) {
        // js配置   WKUserContentController使用者内容控制器
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        // 消息处理程序添加一个脚本
        // WKScriptMessageHandler代理设置   JsCallOC是JS通知WKWebView的名字
        // window.webkit.messageHandlers.JsCallOC.postMessage();
        [userContentController addScriptMessageHandler:self name:@"JsCallOC"];
        
        // WKWebView的配置
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = userContentController;
        
        // 显示WKWebView
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, KWidth, KHeight/2) configuration:configuration];
        _webView.UIDelegate = self; // 设置WKUIDelegate代理
        _webView.navigationDelegate = self; // 设置WKNavigationDelegate代理
        _webView.backgroundColor = [UIColor greenColor];
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, KHeight/2, KWidth, KHeight/2)];
        _bottomView.backgroundColor = [UIColor redColor];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(50, 100, 100, 90);
        [btn setTitle:@"原生调JS" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:btn];
    }
    return _bottomView;
}

@end
