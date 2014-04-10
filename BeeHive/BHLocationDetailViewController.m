//
//  BHLocationDetailViewController.m
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2014-03-11.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import "BHLocationDetailViewController.h"
#import <RestKit/RestKit.h>
#import "BHBuilding.h"
#import "BHLocation.h"
#import "BHDailyStat.h"
#import "BHHourlyStat.h"
#import "BHContributionViewController.h"

@interface BHLocationDetailViewController ()
- (IBAction)contribute:(UIBarButtonItem *)sender;
@property (nonatomic) int max_clients;
@property (nonatomic) int selectedDayIndex;
@property (nonatomic, strong) IBOutlet CPTGraphHostingView *dailyHostView;
@property (strong, nonatomic) IBOutlet CPTGraphHostingView *hourlyHostView;
@property (nonatomic, strong) CPTBarPlot *dailyPlot;
@property (nonatomic, strong) CPTScatterPlot *hourlyPlot;
@property (nonatomic, strong) CPTPlotSpaceAnnotation *priceAnnotation;

-(void)initDailyPlot;
-(void)configureDailyStatGraph;
-(void)configureDailyStatPlots;
-(void)configureDailyStatAxes;

-(void)hideAnnotation:(CPTGraph *)graph;

@end

@implementation BHLocationDetailViewController

@synthesize weeklyStat = _weeklyStat, location = _location, locationStat = _locationStat;
@synthesize max_clients = _max_clients, selectedDayIndex = _selectedDayIndex;
@synthesize locationImageView = _locationImageView, occupancyLabel = _occupancyLabel, btgLabel = _btgLabel;

@synthesize dailyHostView = _dailyHostView, hourlyHostView = _hourlyHostView;
@synthesize dailyPlot = _dailyPlot, hourlyPlot = _hourlyPlot;

CGFloat const CPDBarWidth = 0.25f;
CGFloat const CPDBarInitialX = 0.25f;

-(void)calculateDayAverage:(NSArray *)weeklyStat
{
    int max = 0;
    for (BHDailyStat *dailyStat in weeklyStat) {

        int sum = 0;
        int avg = 0;
        for (BHHourlyStat *hourlyStat in dailyStat.hours) {
            sum += [hourlyStat.clients integerValue];
        }
        
        if (sum != 0) {
            avg = sum/[dailyStat.hours count];
        }
        if (avg > max) {
            max = avg;
        }
        
        dailyStat.clients = [NSString stringWithFormat:@"%d", avg];
    }
    self.max_clients = max;
}

-(void)setLocation:(BHLocation *)location
{
    _location = location;
}

-(int)currentWeeday
{
    // get current day number
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    int weekday = [comps weekday];
    weekday = (weekday + 5) % 7;
    
    return weekday;
}

-(void)setWeeklyStat:(NSArray *)weeklyStat
{
    _weeklyStat = weeklyStat;
    
    // calculate average people for everyday
    [self calculateDayAverage:weeklyStat];
    int weekday = [self currentWeeday];
    self.selectedDayIndex = weekday;
    
//    [self initDailyPlot];
//    [self initHourlyStatPlotForDay:[self currentWeeday]];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = self.location.name;
    
    // set location image and stat
    BHDataController *dataController = [BHDataController sharedDataController];
    self.locationStat = [dataController.locationStats objectForKey:self.location.locId];
    
    // Using SDWebImage to load image
    [self.locationImageView setImageWithURL:[NSURL URLWithString:self.location.photoUrl]
                           placeholderImage:[UIImage imageNamed:@"Beehive.png"]];
    
//    self.occupancyLabel.text = self.locationStat.occupancyPercent;
//    self.btgLabel.text = self.locationStat.bestTime;
    self.occupancyLabel.text = [NSString stringWithFormat:@"%@%%", self.locationStat.occupancyPercent];
    self.btgLabel.text = [NSString stringWithFormat:@"%@", self.locationStat.bestTime];
//    self.queueLabel.text = self.locationStat.queue;
    self.queueLabel.text = self.locationStat.queue;
    
    // Determine label color
    UIColor *titleColor;
    int percentage = [self.locationStat.occupancyPercent integerValue];
    int lowThreshold = [self.locationStat.thresholdMin integerValue];
    int highThreshold = [self.locationStat.thresholdMax integerValue];
    if (percentage <= lowThreshold) {
//        titleColor = [UIColor greenColor];
//        titleColor = [UIColor colorWithRed:0 green:150 blue:0 alpha:1]; //green
    } else if(percentage > lowThreshold && percentage < highThreshold) {
        titleColor =[UIColor orangeColor];
    } else {
//        titleColor = [UIColor redColor];
        titleColor = [UIColor colorWithRed:180 green:0 blue:0 alpha:1]; //red
    }
    self.occupancyLabel.textColor = titleColor;

}

#pragma mark - UIViewController lifecycle methods
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // The plot is initialized here, since the view bounds have not transformed for landscape until now
    
    [self initDailyPlot];
    [self initHourlyStatPlotForDay:[self currentWeeday]];
}

#pragma mark - Chart behavior
-(void)initDailyPlot {
    self.dailyHostView.allowPinchScaling = NO;
    [self configureDailyStatGraph];
    [self configureDailyStatPlots];
    [self configureDailyStatAxes];
}

-(void)configureDailyStatGraph {
    
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.dailyHostView.bounds];
    graph.plotAreaFrame.masksToBorder = NO;
    self.dailyHostView.hostedGraph = graph;
    
    // 2 - Configure the graph
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    graph.paddingBottom = 20.0f;
    graph.paddingLeft  = 30.0f;
    graph.paddingTop    = 0.0f;
    graph.paddingRight  = 10.0f;
    
    // remove border
    graph.plotAreaFrame.borderLineStyle = nil;
    
    // 3 - Set up styles
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor grayColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 14.0f;
    
    // 4 - Set up title
    NSString *title = @"Average occupancy (%)";
    graph.title = title;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(-55.0f, 5.0f); // title position
    
    // 5 - Set up plot space
    CGFloat xMin = -0.3f;
    CGFloat xMax = [self.weeklyStat count];
    CGFloat yMin = 0.0f;
    CGFloat yMax = self.max_clients * 1.4;  // should determine dynamically based on max number of people
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
    
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
}

-(void)configureDailyStatPlots {
    
    // 1 - Set up the plot
//    self.dailyPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor] horizontalBars:NO];
    
    self.dailyPlot = [[CPTBarPlot alloc] init];
    self.dailyPlot.fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:255/255.0f green:159.0/255.0f blue:0.0/255 alpha:1]];
    
    self.dailyPlot.identifier = CPDTickerSymbolGOOG;
    
    // 2 - Set up line style
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineColor = [CPTColor clearColor];
    barLineStyle.lineWidth = 0.5;
    
    // 3 - Add plots to graph
    CPTGraph *graph = self.dailyHostView.hostedGraph;
    CGFloat barX = CPDBarInitialX;
    
    self.dailyPlot.dataSource = self;
    self.dailyPlot.delegate = self;
    self.dailyPlot.barWidth = CPTDecimalFromDouble(CPDBarWidth*3);
    self.dailyPlot.barOffset = CPTDecimalFromDouble(barX);
    self.dailyPlot.lineStyle = barLineStyle;
    [graph addPlot:self.dailyPlot toPlotSpace:graph.defaultPlotSpace];
    
}

-(void)configureDailyStatAxes {
    // 1 - Configure styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor grayColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 8.0f;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [[CPTColor grayColor] colorWithAlphaComponent:1];
    
    CPTMutableTextStyle *lablingStyle = [CPTMutableTextStyle textStyle];
    lablingStyle.color = [CPTColor grayColor];
    lablingStyle.fontName = @"Helvetica-Bold";
    lablingStyle.fontSize = 8.0f;
    
    //Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth            = 0.75;
    majorGridLineStyle.lineColor            = [[CPTColor grayColor] colorWithAlphaComponent:0.2];
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth            = 0.25;
    minorGridLineStyle.lineColor            = [[CPTColor grayColor] colorWithAlphaComponent:0.2];
    
    // 2 - Get the graph's axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.dailyHostView.hostedGraph.axisSet;
    
    // 3 - Configure the x-axis
    
    CPTXYAxis *x = axisSet.xAxis;
    x.orthogonalCoordinateDecimal = CPTDecimalFromInt(0);
    x.majorIntervalLength = CPTDecimalFromInt(1);
    x.minorTicksPerInterval = 0;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.majorGridLineStyle = majorGridLineStyle;
    x.labelTextStyle = lablingStyle;
    x.labelOffset = -8.0f;
    x.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    
    int labelLocations = 0;
    NSMutableArray *customXLabels = [NSMutableArray array];
    NSArray *days = [NSArray arrayWithObjects:@"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", @"Sun", nil];
    for (NSString *day in days) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:day textStyle:x.labelTextStyle];
        newLabel.tickLocation   = [[NSNumber numberWithDouble:(labelLocations + 0.3)] decimalValue]; // change 0.3 to set label in middle of bar
        newLabel.offset         = x.labelOffset + x.majorTickLength;
        newLabel.rotation       = M_PI / 4;
        [customXLabels addObject:newLabel];
        labelLocations++;
    }
    x.axisLabels = [NSSet setWithArray:customXLabels];
    
    // 4 - Configure the y-axis
    
    CPTXYAxis *y = axisSet.yAxis;
    y.title = @"";
    y.titleOffset = 2.0f;
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.labelTextStyle = lablingStyle;  // y axis label style
    y.labelOffset = -2.0f; // distance between label and graph
    y.majorGridLineStyle = majorGridLineStyle;
    y.minorGridLineStyle = minorGridLineStyle;
    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    
}

// *******************************************************************************************
//
//                     Hourly Stat Plot Initialization
//
// *******************************************************************************************

//configure hourly stat
#pragma mark - Chart behavior
-(void)initHourlyStatPlotForDay:(int)dayIndex {
    self.hourlyHostView.allowPinchScaling = YES;
    [self configureHourlyStatGraph:dayIndex];
    [self configureHourlyStatPlots:dayIndex];
    [self configureHourlyStatAxes:dayIndex];
}

-(void)configureHourlyStatGraph:(int)dayIndex {
    
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hourlyHostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    
    graph.plotAreaFrame.masksToBorder = NO;
    graph.plotAreaFrame.borderLineStyle = nil;
    graph.paddingBottom = 20.0f;
    graph.paddingLeft  = 30.0f;
    graph.paddingTop    = 0.0f;
    graph.paddingRight  = 10.0f;
    
    self.hourlyHostView.hostedGraph = graph;
    
    // 2 - Set graph title

    NSArray *dayOfWeek = [NSArray arrayWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday", nil];
    NSString *title = [NSString stringWithFormat:@"%@ (%%)", [dayOfWeek objectAtIndex:self.selectedDayIndex]];
    graph.title = title;
    
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor grayColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 14.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(-95.0f, 10.0f);
    
    // 4 - Set padding for plot area
//    [graph.plotAreaFrame setPaddingLeft:30.0f];
//    [graph.plotAreaFrame setPaddingBottom:30.0f];
    
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
}

-(void)configureHourlyStatPlots:(int)dayIndex {
    
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hourlyHostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    // 2 - Create the three plots
    
    self.hourlyPlot = [[CPTScatterPlot alloc] init];
    
    self.hourlyPlot.dataSource = self;
    self.hourlyPlot.identifier = CPDTickerSymbolGOOG;
    
    CPTColor *googColor = [CPTColor greenColor];
    [graph addPlot:self.hourlyPlot toPlotSpace:plotSpace];
    
    // 3 - Set up plot space
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:self.hourlyPlot, nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.3f)];
    plotSpace.yRange = yRange;
    
    // 4 - Create styles and symbols
    CPTMutableLineStyle *googLineStyle = [self.hourlyPlot.dataLineStyle mutableCopy];
    googLineStyle.lineWidth = 1.0;
    googLineStyle.lineColor = googColor;
    self.hourlyPlot.dataLineStyle = googLineStyle;
    CPTMutableLineStyle *googSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    googSymbolLineStyle.lineColor = googColor;
    CPTPlotSymbol *googSymbol = [CPTPlotSymbol plotSymbol];
    googSymbol.fill = [CPTFill fillWithColor:googColor];
    googSymbol.lineStyle = googSymbolLineStyle;
    googSymbol.size = CGSizeMake(6.0f, 6.0f);
    self.hourlyPlot.plotSymbol = googSymbol;
}

-(void)configureHourlyStatAxes:(int)dayIndex {
    
    BHDailyStat *dailyStat = [self.weeklyStat objectAtIndex:dayIndex];
    
    // 1 - Configure styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor grayColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 8.0f;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [[CPTColor grayColor] colorWithAlphaComponent:1];
    
    CPTMutableTextStyle *lablingStyle = [CPTMutableTextStyle textStyle];
    lablingStyle.color = [CPTColor grayColor];
    lablingStyle.fontName = @"Helvetica-Bold";
    lablingStyle.fontSize = 8.0f;
    
    //Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth            = 0.75;
    majorGridLineStyle.lineColor            = [[CPTColor grayColor] colorWithAlphaComponent:0.2];
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth            = 0.25;
    minorGridLineStyle.lineColor            = [[CPTColor grayColor] colorWithAlphaComponent:0.2];
    
    // 2 - Get the graph's axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hourlyHostView.hostedGraph.axisSet;
    
    // 3 - Configure the x-axis
    CPTXYAxis *x = axisSet.xAxis;
    x.orthogonalCoordinateDecimal = CPTDecimalFromInt(0);
    x.majorIntervalLength = CPTDecimalFromInt(1);
    x.minorTicksPerInterval = 0;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.majorGridLineStyle = majorGridLineStyle;
    x.labelTextStyle = lablingStyle;
    x.labelOffset = 2.0f;
    x.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    
    CGFloat hourCount = [dailyStat.hours count];
    
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:hourCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:hourCount];
    NSInteger i = 0;
    
    for (BHHourlyStat *hourlyStat in dailyStat.hours) {
        CPTAxisLabel *label;
        BOOL showLabel = [hourlyStat.hour hasSuffix:@"00:00"];
        if ( showLabel ) {
             label = [[CPTAxisLabel alloc] initWithText:[hourlyStat.hour substringToIndex:5]  textStyle:x.labelTextStyle];
        } else {
            label = [[CPTAxisLabel alloc] initWithText:@"" textStyle:x.labelTextStyle];
        }

        CGFloat location = i++;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        label.rotation = M_PI / 4;
        
        if (label) {
            [xLabels addObject:label];
            if (showLabel) {
                [xLocations addObject:[NSNumber numberWithFloat:location]];
            }
        }
    }
    
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    
    // 4 - Configure y-axis
    CPTXYAxis *y = axisSet.yAxis;
    y.title = @"";
    y.titleOffset = 2.0f;
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.labelTextStyle = lablingStyle;  // y axis label style
    y.labelOffset = -2.0f; // distance between label and graph
    y.majorGridLineStyle = majorGridLineStyle;
    y.minorGridLineStyle = minorGridLineStyle;
    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    
}


#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    if ([plot isKindOfClass:[CPTBarPlot class]]) {
        return [self.weeklyStat count];
    } else if ([plot isKindOfClass:[CPTScatterPlot class]]) {
        BHDailyStat *dailyStat = [self.weeklyStat objectAtIndex:self.selectedDayIndex ];
        return [dailyStat.hours count];
        //        return [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
    }
    return 1;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    if ([plot isKindOfClass:[CPTBarPlot class]]) {
        if ((fieldEnum == CPTBarPlotFieldBarTip) && (index < [self.weeklyStat count])) {
            if ([plot.identifier isEqual:CPDTickerSymbolGOOG]) {
                BHDailyStat *dayStat = [self.weeklyStat objectAtIndex:index];
                return [NSNumber numberWithInt:[dayStat.clients integerValue]];
                //                return [NSNumber numberWithUnsignedInteger:index*10];
            }
        }
    } else if ([plot isKindOfClass:[CPTScatterPlot class]]) {
        // Examples
        //        NSInteger valueCount = [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
        BHDailyStat *dailyStat = [self.weeklyStat objectAtIndex:self.selectedDayIndex];
        NSInteger valueCount = [dailyStat.hours count];
        
        switch (fieldEnum) {
            case CPTScatterPlotFieldX:
                if (index < valueCount) {
                    return [NSNumber numberWithUnsignedInteger:index];
                }
                break;
                
            case CPTScatterPlotFieldY:
                if ([plot.identifier isEqual:CPDTickerSymbolGOOG] == YES) {
                    BHHourlyStat *hourlyStat = [dailyStat.hours objectAtIndex:index]; // get day stat instance
                    return [NSNumber numberWithInt:[hourlyStat.clients integerValue]];
                }
                break;
        }
        return [NSDecimalNumber zero];
    }
    
    return [NSDecimalNumber numberWithUnsignedInteger:index];
}

#pragma mark - CPTBarPlotDelegate methods
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index {
    // 1 - Is the plot hidden?
    if (plot.isHidden == YES) {
        return;
    }
    // 2 - Create style, if necessary
    static CPTMutableTextStyle *style = nil;
    if (!style) {
        style = [CPTMutableTextStyle textStyle];
        style.color= [CPTColor grayColor];
        style.fontSize = 13.0f;
        style.fontName = @"Helvetica-Bold";
    }
    
    // 3 - Create annotation, if necessary
    NSNumber *price = [self numberForPlot:plot field:CPTBarPlotFieldBarTip recordIndex:index];
    if (!self.priceAnnotation) {
        NSNumber *x = [NSNumber numberWithInt:0];
        NSNumber *y = [NSNumber numberWithInt:0];
        NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
        self.priceAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
    }
    
    // 4 - Create number formatter, if needed
    static NSNumberFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setMaximumFractionDigits:2];
    }
    
    // 5 - Create text layer for annotation
//    NSString *priceValue = [formatter stringFromNumber:price];
    NSString *occupancyValue = [NSString stringWithFormat:@"%@%%", price];
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:occupancyValue style:style];
    self.priceAnnotation.contentLayer = textLayer;
    // 6 - Get plot index based on identifier
    NSInteger plotIndex = 0;
    if ([plot.identifier isEqual:CPDTickerSymbolGOOG] == YES) {
        plotIndex = 0;
    }
    
    // 7 - Get the anchor point for annotation
    CGFloat x = index + CPDBarInitialX + (plotIndex * CPDBarWidth);
    NSNumber *anchorX = [NSNumber numberWithFloat:x];
    CGFloat y = [price floatValue] + (self.max_clients*1.4)/15;  // control location of annotation
    NSNumber *anchorY = [NSNumber numberWithFloat:y];
    self.priceAnnotation.anchorPlotPoint = [NSArray arrayWithObjects:anchorX, anchorY, nil];
    
    // 8 - Add the annotation
    [plot.graph.plotAreaFrame.plotArea addAnnotation:self.priceAnnotation];
    
    // 9 - reload data for hourly stat
    self.selectedDayIndex = index;
    [self initHourlyStatPlotForDay:index];
//    [self.hourlyPlot reloadData];

}

-(void)hideAnnotation:(CPTGraph *)graph {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showContributionView"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        BHContributionViewController *contribViewController = [[navigationController viewControllers] objectAtIndex:0];
        contribViewController.location = self.location;
    }
}


- (IBAction)contribute:(UIBarButtonItem *)sender {
    
}
@end
