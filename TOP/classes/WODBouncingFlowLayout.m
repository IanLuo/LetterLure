//
//  WODBouncingFlowLayout.m
//  TOP
//
//  Created by ianluo on 14-2-28.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODBouncingFlowLayout.h"

@implementation WODBouncingFlowLayout

-(id)init {
	if (!(self = [super init])) return nil;
		
	self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
	self.visibleIndexPathsSet = [NSMutableSet set];
	
	return self;
}

- (void)prepareLayout
{
	[super prepareLayout];
	
	CGRect visibleRect = CGRectInset((CGRect){.origin = self.collectionView.bounds.origin, .size = self.collectionView.frame.size}, -100, -100);
	
	NSArray *itemsInVisibleRectArray = [super layoutAttributesForElementsInRect:visibleRect];
	NSSet *itemsIndexPathsInVisibleRectSet = [NSSet setWithArray:[itemsInVisibleRectArray valueForKey:@"indexPath"]];
	
	NSArray *noLongerVisibleBehaviours = [self.dynamicAnimator.behaviors filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behaviour, NSDictionary *bindings) {
		BOOL currentlyVisible = [itemsIndexPathsInVisibleRectSet member:[[[behaviour items] lastObject] indexPath]] != nil;
		return !currentlyVisible;
	}]];
	
	[noLongerVisibleBehaviours enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
		[self.dynamicAnimator removeBehavior:obj];
		[self.visibleIndexPathsSet removeObject:[[[obj items] lastObject] indexPath]];
	}];
	
	NSArray *newlyVisibleItems = [itemsInVisibleRectArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
		BOOL currentlyVisible = [self.visibleIndexPathsSet member:item.indexPath] != nil;
		return !currentlyVisible;
	}]];
	
	CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
	
	[newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger idx, BOOL *stop) {
		CGPoint center = item.center;
		UIAttachmentBehavior *springBehaviour = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:center];
		
		springBehaviour.length = 0.0f;
		springBehaviour.damping = 0.8f;
		springBehaviour.frequency = 1.0f;
		
		if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
			CGFloat distanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
			CGFloat scrollResistance = distanceFromTouch / 1500.0f;
			
			if (self.latestDelta < 0) {
				center.y += MAX(self.latestDelta, self.latestDelta*scrollResistance);
			}
			else {
				center.y += MIN(self.latestDelta, self.latestDelta*scrollResistance);
			}
			item.center = center;
		}
		
		[self.dynamicAnimator addBehavior:springBehaviour];
		[self.visibleIndexPathsSet addObject:item.indexPath];
	}];
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	return [self.dynamicAnimator itemsInRect:rect];
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
	UIScrollView *scrollView = self.collectionView;
	CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
	
	self.latestDelta = delta;
	
	CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
	
	[self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
		CGFloat distanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
		CGFloat scrollResistance = distanceFromTouch / 500.0f;
		
		UICollectionViewLayoutAttributes *item = [springBehaviour.items firstObject];
		CGPoint center = item.center;
		if (delta < 0) {
			center.y += MAX(delta, delta*scrollResistance);
		}
		else {
			center.y += MIN(delta, delta*scrollResistance);
		}
		item.center = center;
		
		[self.dynamicAnimator updateItemUsingCurrentState:item];
	}];
	
	return NO;
}

@end
