//
//  WODIAPCenter.m
//  TOP
//
//  Created by ianluo on 14-4-8.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODIAPCenter.h"

NSString * const iapEffectMetal = @"metal";
NSString * const iapEffectColors = @"colors";
NSString * const iapEffectGlass = @"glass";
NSString * const iapEffectGradient = @"gradient";
NSString * const iapEffectNeon = @"neon";
NSString * const iapEffectHoney = @"valentines";
NSString * const iapEffectAnimals = @"animals";
NSString * const iapEffectWater = @"water";
NSString * const iapExtraFonts = @"extralFonts";

@implementation SKProduct (LocalizedPrice)

- (NSString *)localizedPrice
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    return formattedString;
}
@end

@interface WODIAPCenter()<SKProductsRequestDelegate,SKPaymentTransactionObserver>
{
	void (^purchaseCompleteAction)(NSString * completeMessage);
	void (^restoreCompeteAction)(BOOL status);
}

@end

@implementation WODIAPCenter
#pragma mark Singlton
+ (WODIAPCenter*)sharedSingleton
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}


- (NSArray *)freePackages
{
	if (!_freePackages)
	{
		_freePackages = @[@"animals",@"water"];
	}
	return _freePackages;
}

#define key_purchased_packages @"purchased_packages"

- (BOOL)checkIsPackageReady:(NSString *)packageName
{
	return  [self isPurchased:packageName] || ([packageName isEqualToString:@"defaultPackage"]);
}

- (BOOL)isPurchased:(NSString *)packageName
{
	return [self.purchasedPackages containsObject:packageName];
}

- (NSArray *)purchasedPackages
{
	return [[NSUserDefaults standardUserDefaults]objectForKey:key_purchased_packages];
}

- (void)purchasePackage:(NSString *)packageName complete:(void(^)(NSString * message))actoin
{
	purchaseCompleteAction = actoin;
	
	[self requestProductData:packageName];

//#warning this is only for test! remember to comment out when release
//	[self purchaseCompleteForPackage:packageName success:YES];
}

- (void)restorePaymentsComplete:(void(^)(BOOL status))actoin
{
	restoreCompeteAction = actoin;
	
	[self restorePurchase];
}

- (void)purchaseCompleteForPackage:(NSString *)packageName success:(BOOL)status
{
	if (status)
	{
		NSMutableArray * mutableArray = [NSMutableArray arrayWithArray:[self purchasedPackages]];
		
		[mutableArray addObject:packageName];
		
		[[NSUserDefaults standardUserDefaults]setObject:[NSArray arrayWithArray:mutableArray] forKey:key_purchased_packages];
		[[NSUserDefaults standardUserDefaults]synchronize];
		
		if (purchaseCompleteAction) {
			purchaseCompleteAction([NSString stringWithFormat:@"%@ %@",NSLocalizedString(packageName, nil), NSLocalizedString(@"PURCHASE_SUCCESS", nil)]);
		}
	}
}

#pragma mark - store kit delegates and public methods

- (void)loadStore
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
}

- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

- (void)restorePurchase{
#ifdef DEBUGMODE
	NSLog(@"(%@,%i) Start Restoring Purchase",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__);
#endif

    [[SKPaymentQueue defaultQueue]restoreCompletedTransactions];
}

-(void)requestProductData:(NSString *)productID
{
#ifdef DEBUGMODE
	NSLog(@"(%@,%i) Start Purchasing:%@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__,productID);
#endif
    
    NSSet *productIdentifiers = [NSSet setWithObject:productID];
	
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
    // we will release the request object in the delegate callback
}

//- (void)recordTransaction:(SKPaymentTransaction *)transaction
//{
//    NSString *receptKey = [transaction.payment.productIdentifier stringByAppendingFormat:@"%@",@"_reception"];
//	[[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:receptKey];
//    
//	[[NSUserDefaults standardUserDefaults] synchronize];
//}

//- (void)provideContent:(NSString *)productId
//{
//	[self purchaseCompleteForPackage:productId success:YES];
//}

- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
//        [self ]
    }else
    {
        // send out a notification for the failed transaction
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
//    [self recordTransaction:transaction];
    [self purchaseCompleteForPackage:transaction.payment.productIdentifier success:YES];
    [self finishTransaction:transaction wasSuccessful:YES];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.originalTransaction == nil) {
#ifdef DEBUGMODE
		NSLog(@"(%@,%i):invalide restore transaction %@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__,transaction.transactionIdentifier);
#endif

        [self finishTransaction:transaction wasSuccessful:NO];
        return;
    }
    
//    [self recordTransaction:transaction.originalTransaction];
    [self purchaseCompleteForPackage:transaction.originalTransaction.payment.productIdentifier success:YES];
    [self finishTransaction:transaction wasSuccessful:YES];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    SKProduct *proUpgradeProduct = [products count] > 0 ? [products objectAtIndex:0] : nil;
    if (proUpgradeProduct)
    {
#ifdef DEBUGMODE
		NSLog(@"(%@,%i):initing",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__);
        NSLog(@"(%@,%i) Product title: %@" ,[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__, proUpgradeProduct.localizedTitle);
        NSLog(@"(%@,%i) Product description: %@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__, proUpgradeProduct.localizedDescription);
        NSLog(@"(%@,%i) Product price: %@" ,[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__, proUpgradeProduct.price);
        NSLog(@"(%@,%i) Product id: %@" ,[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__, proUpgradeProduct.productIdentifier);
#endif
        
        SKPayment *payment = [SKPayment paymentWithProduct:proUpgradeProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }else{
		UIAlertView *alertView = [[UIAlertView alloc]init];
		[alertView setTitle:@"Can't Purchase"];
		[alertView setMessage:@"Error happend, please try again later."];
		[alertView addButtonWithTitle:@"OK"];
		[alertView setCancelButtonIndex:0];
		[alertView show];
        
        for (NSString *invalidProductId in response.invalidProductIdentifiers)
        {
#ifdef DEBUGMODE
			NSLog(@"(%@,%i) Invalid product id: %@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__,invalidProductId);
#endif
            return;
        }
        
        NSLog(@"(%@,%i) No product found %@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__,request);
	}
}
#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
	
#ifdef DEBUGMODE
	NSLog(@"(%@,%i):received restored transactions: %lul",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__,(unsigned long)queue.transactions.count);
#endif
    
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSString *productID = transaction.payment.productIdentifier;
        [purchasedItemIDs addObject:productID];
		
#ifdef DEBUGMODE
		NSLog(@"(%@,%i):product id is %@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__, productID);
#endif
        // here put an if/then statement to write files based on previously purchased items
		[self purchaseCompleteForPackage:productID success:YES];
    }
	
	if (restoreCompeteAction)
	{
		restoreCompeteAction(YES);
	}
}

@end
