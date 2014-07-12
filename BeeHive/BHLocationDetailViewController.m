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
#import "BHUtils.h"

@interface BHLocationDetailViewController ()
- (IBAction)contribute:(UIBarButtonItem *)sender;
@property (nonatomic) int max_clients;
@property (nonatomic) int selectedDayIndex;
@property (nonatomic) int currentIndex;
@property (nonatomic, strong) IBOutlet CPTGraphHostingView *dailyHostView;
@property (strong, nonatomic) IBOutlet CPTGraphHostingView *hourlyHostView;
@property (nonatomic, strong) CPTBarPlot *dailyPlot;
@property (nonatomic, strong) CPTBarPlot *dailyPlotAAPL;
@property (nonatomic, strong) CPTBarPlot *dailyPlotLACROIX;
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
@synthesize indicator = _indicator;

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
    int weekday = (int)[comps weekday];
    weekday = (weekday + 5) % 7;
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"EST"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:timeZone];
    NSString *newDate = [dateFormatter stringFromDate:now];
    NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc] init];
    [newDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *todayInAtlanta = [newDateFormatter dateFromString:newDate];
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:todayInAtlanta];
    
    // TODO: change to GMT time to solve timezone issue
    self.currentIndex = ([components hour]+1) * 4 + round((double)[components minute]/15);
    
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

-(void)loadLocationImageAndStat
{
    // set location image and stat
    BHDataController *dataController = [BHDataController sharedDataController];
    self.locationStat = [dataController.locationStats objectForKey:self.location.locId];
    
    // Using SDWebImage to load image
    [self.locationImageView setImageWithURL:[NSURL URLWithString:self.location.photoUrl]
                           placeholderImage:[UIImage imageNamed:@"Beehive.png"]];
    
    self.occupancyLabel.text = [NSString stringWithFormat:@"%@%% of %@", self.locationStat.occupancyPercent, self.locationStat.maxCapacity];
    self.btgLabel.text = [NSString stringWithFormat:@"%@", self.locationStat.bestTime];
    self.queueLabel.text = self.locationStat.queue;
    
    // Determine label color
    self.occupancyLabel.textColor = [BHUtils titleColorForLocationStat:self.locationStat];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = self.location.name;
    
    [self loadLocationImageAndStat];

    // init plot
    [self initDailyPlot];
    [self initHourlyStatPlotForDay:[self currentWeeday]];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self loadLocationImageAndStat];

}


#pragma mark - Chart behavior Daly
-(void)initDailyPlot {
    if (!self.weeklyStat) {
        self.indicator.hidden = NO;
        [self.indicator startAnimating];
    } else {
        [self.indicator stopAnimating];
        self.indicator.hidden = YES;
    }
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
//    titleStyle.color = [CPTColor colorWithComponentRed:247.0f/255.0f green:148.0/255.0f blue:30.0/255 alpha:1.0f]; // couleur orange BeeHive;
//    [titleStyle setValue:[BHUtils titleColorForLocationStat2:self.locationStat] forKey:@"color"];
    titleStyle.color = [CPTColor grayColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 14.0f;
    
    // 4 - Set up title
    NSString *title = @"Average occupancy (%)";
    graph.title = title;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
//    graph.titleDisplacement = CGPointMake(-55.0f, 5.0f); // title position
    
    // 5 - Set up plot space
    CGFloat xMin = -0.3f;
    CGFloat xMax = [self.weeklyStat count];
    CGFloat yMin = 0.0f;
    CGFloat yMax = [self.locationStat.occupancyPercent floatValue] * 1.15;
    // should determine dynamically based on max number of people //
    if (yMax < self.max_clients * 1.5){
        yMax = self.max_clients * 1.5;
    }
    if (IS_IPAD) {
        if (yMax < self.max_clients * 1.4){
            yMax = self.max_clients * 1.4;
        }
    }
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
}

-(void)configureDailyStatPlots {
    
    // 1 - Set up the plot
//    self.dailyPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor] horizontalBars:NO]; // bof le style
    //    self.dailyPlot.fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:247.0f/255.0f green:148.0/255.0f blue:30.0/255 alpha:1.0f]]; // couleur orange BeeHive
    //    self.dailyPlot.fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:247.0f/255.0f green:148.0/255.0f blue:30.0/255 alpha:0.7f]]; // couleur orange BeeHive
    
    // pour les autres jours
    self.dailyPlot = [[CPTBarPlot alloc] init];
    self.dailyPlot.fill = [CPTFill fillWithColor:[[CPTColor grayColor] colorWithAlphaComponent:0.3]];
    self.dailyPlot.identifier = CPDTickerSymbolGOOG;
    
    // For current day
    self.dailyPlotAAPL = [[CPTBarPlot alloc] init];
    self.dailyPlotAAPL.fill = [CPTFill fillWithColor:[[CPTColor grayColor] colorWithAlphaComponent:0.6]];
    self.dailyPlotAAPL.identifier = CPDTickerSymbolAAPL;
    
    // Occupancy clue
    self.dailyPlotLACROIX = [[CPTBarPlot alloc] init]; // la bare de la Croix
    self.dailyPlotLACROIX.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    self.dailyPlotLACROIX.identifier = CPDTickerSymbolLACROIX;
    
    
    // 2 - Set up line style
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineColor = [CPTColor clearColor];
    barLineStyle.lineWidth = 0.5;
    CPTMutableLineStyle *barLineStyleAAPL = [[CPTMutableLineStyle alloc] init]; // For today
    barLineStyleAAPL.lineColor = [CPTColor clearColor];
    barLineStyleAAPL.lineWidth = 0.5;
    CPTMutableLineStyle *barLineStyleLACROIX = [[CPTMutableLineStyle alloc] init]; // Et pour la Croix...
    [barLineStyleLACROIX setValue:[BHUtils titleColorForLocationStat:self.locationStat] forKey:@"lineColor"];
    barLineStyleLACROIX.lineWidth = 1;
    
    
    // Configure annimation 
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    [anim setDuration:1.0f];
    anim.toValue = [NSNumber numberWithFloat:1.0f];
    anim.fromValue = [NSNumber numberWithFloat:0.0f];
    anim.removedOnCompletion = NO;
    anim.delegate = self;
    anim.fillMode = kCAFillModeForwards;
    self.dailyPlot.anchorPoint = CGPointMake(0.0, 0.0);
    self.dailyPlotAAPL.anchorPoint = CGPointMake(0.0, 0.0);
//    self.dailyPlotLACROIX.anchorPoint = CGPointMake(0.0, 0.0);
    [self.dailyPlot addAnimation:anim forKey:@"grow"];
    [self.dailyPlotAAPL addAnimation:anim forKey:@"grow"];
//    [self.dailyPlotLACROIX addAnimation:anim forKey:@"grow"];
    
    // 3 - Add plots to graph
    CPTGraph *graph = self.dailyHostView.hostedGraph;
    CGFloat barX = CPDBarInitialX;
    self.dailyPlot.dataSource = self; // Pour les autres jours
    self.dailyPlot.delegate = self;
    self.dailyPlot.barWidth = CPTDecimalFromDouble(CPDBarWidth*3);
    self.dailyPlot.barOffset = CPTDecimalFromDouble(barX);
    self.dailyPlot.lineStyle = barLineStyle;
    [graph addPlot:self.dailyPlot toPlotSpace:graph.defaultPlotSpace];
    self.dailyPlotAAPL.dataSource = self; // For today
    self.dailyPlotAAPL.delegate = self;
    self.dailyPlotAAPL.barWidth = CPTDecimalFromDouble(CPDBarWidth*3);
    self.dailyPlotAAPL.barOffset = CPTDecimalFromDouble(barX);
    self.dailyPlotAAPL.lineStyle = barLineStyle;
    [graph addPlot:self.dailyPlotAAPL toPlotSpace:graph.defaultPlotSpace];
    self.dailyPlotLACROIX.dataSource = self; // Et pour la Croix...
    self.dailyPlotLACROIX.barWidth = CPTDecimalFromDouble(CPDBarWidth*3);
    self.dailyPlotLACROIX.barOffset = CPTDecimalFromDouble(barX);
    self.dailyPlotLACROIX.lineStyle = barLineStyleLACROIX;
    [graph addPlot:self.dailyPlotLACROIX toPlotSpace:graph.defaultPlotSpace];
    
}

-(void)configureDailyStatAxes {
    // 1 - Configure styles
//    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
////    axisTitleStyle.color = [CPTColor colorWithComponentRed:247.0f/255.0f green:148.0/255.0f blue:30.0/255 alpha:1.0f]; // couleur orange BeeHive;
//    [axisTitleStyle setValue:[BHUtils titleColorForLocationStat2:self.locationStat] forKey:@"color"];
//    axisTitleStyle.fontName = @"Helvetica-Bold";
//    axisTitleStyle.fontSize = 8.0f;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor blackColor];
    
    CPTMutableTextStyle *lablingStyle = [CPTMutableTextStyle textStyle];
//    lablingStyle.color = [CPTColor colorWithComponentRed:247.0f/255.0f green:148.0/255.0f blue:30.0/255 alpha:1.0f]; // couleur orange BeeHive;
    [lablingStyle setValue:[BHUtils titleColorForLocationStat2:self.locationStat] forKey:@"color"];
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
#pragma mark - Chart behavior Hourly
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
//    titleStyle.color = [CPTColor colorWithComponentRed:247.0f/255.0f green:148.0/255.0f blue:30.0/255 alpha:1.0f]; // couleur orange BeeHive
//    [titleStyle setValue:[BHUtils titleColorForLocationStat2:self.locationStat] forKey:@"color"];
    titleStyle.color = [CPTColor grayColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 14.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
//    graph.titleDisplacement = CGPointMake(-95.0f, 10.0f);
    
    // 4 - Set padding for plot area
//    [graph.plotAreaFrame setPaddingLeft:30.0f];
//    [graph.plotAreaFrame setPaddingBottom:30.0f];
    
    // 5 - Enable user interactions for plot space
//    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
//    plotSpace.allowsUserInteraction = YES;
    
    // Fit plot space
    
    
}


-(void)configureHourlyStatPlots:(int)dayIndex {
    
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hourlyHostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    // 2 - Create the 2 plots ##
    self.hourlyPlot = [[CPTScatterPlot alloc] init];
    self.hourlyPlot.dataSource = self;
    self.hourlyPlot.identifier = CPDTickerSymbolGOOG;
//    CPTColor *googColor = [CPTColor colorWithComponentRed:247.0f/255.0f green:148.0/255.0f blue:30.0/255 alpha:1.0f]; // orange BeeHive
    CPTScatterPlot *laCroixPlot = [[CPTScatterPlot alloc] init]; //pour la Croix
    laCroixPlot.dataSource = self;
    laCroixPlot.identifier = CPDTickerSymbolLACROIX;
    CPTColor *laCroixColor = [CPTColor clearColor];
    // Configure annimation
//    self.hourlyPlot.opacity = 0.0f;
//    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    fadeInAnimation.duration = 1.0f;
//    fadeInAnimation.removedOnCompletion = NO;
//    fadeInAnimation.fillMode = kCAFillModeForwards;
//    fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
//    [self.hourlyPlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    [anim setDuration:0.5f];
    anim.toValue = [NSNumber numberWithFloat:1.0f];
    anim.fromValue = [NSNumber numberWithFloat:0.0f];
    anim.removedOnCompletion = NO;
    anim.delegate = self;
    anim.fillMode = kCAFillModeForwards;
    self.hourlyPlot.anchorPoint = CGPointMake(0.0, 0.0);
    [self.hourlyPlot addAnimation:anim forKey:@"grow"];
    // add plot to graph
    [graph addPlot:self.hourlyPlot toPlotSpace:plotSpace];
    [graph addPlot:laCroixPlot toPlotSpace:plotSpace];
    
    
    // 3 - Set up plot space
//    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:self.hourlyPlot, nil]];
    [plotSpace scaleToFitPlots:[graph allPlots]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    if (IS_IPAD) {
        [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.5f)];
    } else {
        
        [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.6f)];
    }
    plotSpace.yRange = yRange;
    
    
    // 4 - Create styles and symbols
    CPTMutableLineStyle *googLineStyle = [self.hourlyPlot.dataLineStyle mutableCopy];
    googLineStyle.lineWidth = 1.0;
//    googLineStyle.lineColor = googColor;
    googLineStyle.lineColor = [CPTColor grayColor];
    self.hourlyPlot.dataLineStyle = googLineStyle;
    //CPTMutableLineStyle *googSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    //googSymbolLineStyle.lineColor = [CPTColor grayColor];
    //CPTPlotSymbol *googSymbol = [CPTPlotSymbol plotSymbol];
    //googSymbol.fill = [CPTFill fillWithColor:[CPTColor grayColor]];
    //googSymbol.lineStyle = googSymbolLineStyle;
    //googSymbol.size = CGSizeMake(6.0f, 6.0f);
    //self.hourlyPlot.plotSymbol = googSymbol;

    CPTMutableLineStyle *laCroixLineStyle = [laCroixPlot.dataLineStyle mutableCopy];
    laCroixLineStyle.lineWidth = 1.0;
    laCroixLineStyle.lineColor = laCroixColor;
    laCroixPlot.dataLineStyle = laCroixLineStyle;
    
}

-(void)configureHourlyStatAxes:(int)dayIndex {
    
    BHDailyStat *dailyStat = [self.weeklyStat objectAtIndex:dayIndex];
    
    // 1 - Configure styles
//    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
//    axisTitleStyle.color = [CPTColor colorWithComponentRed:247.0f/255.0f green:148.0/255.0f blue:30.0/255 alpha:1.0f]; // couleur orange BeeHive
//    [axisTitleStyle setValue:[BHUtils titleColorForLocationStat2:self.locationStat] forKey:@"color"];
//    axisTitleStyle.color = [CPTColor grayColor];
//    axisTitleStyle.fontName = @"Helvetica-Bold";
//    axisTitleStyle.fontSize = 8.0f;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor blackColor];
    CPTMutableTextStyle *lablingStyle = [CPTMutableTextStyle textStyle];
//    lablingStyle.color = [CPTColor colorWithComponentRed:247.0f/255.0f green:148.0/255.0f blue:30.0/255 alpha:1.0f]; // couleur orange BeeHive
    [lablingStyle setValue:[BHUtils titleColorForLocationStat2:self.locationStat] forKey:@"color"];
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

// La croix
-(CPTPlotSymbol *)symbolForScatterPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    if (index == self.currentIndex && [plot.identifier isEqual:CPDTickerSymbolLACROIX] == YES) {
        // calculate index position based on current time
        CPTPlotSymbol *plotSymbol = [CPTPlotSymbol plusPlotSymbol];
        CPTLineStyle *lineStyle = [CPTLineStyle lineStyle];
        [lineStyle setValue:[BHUtils titleColorForLocationStat:self.locationStat] forKey:@"lineColor"];
        // [lineStyle setValue:[CPTColor colorWithComponentRed:247.0f/255.0f green:148.0/255.0f blue:30.0/255 alpha:1.0f] forKey:@"lineColor"];
        plotSymbol.lineStyle = lineStyle;
        plotSymbol.size = CGSizeMake(20, 20);
        return plotSymbol;
    }
    return [CPTPlotSymbol plotSymbol];
}


//***************
// DATA
//***************
#pragma mark - Data
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *occupancy = [f numberFromString:self.locationStat.occupancyPercent];
    
    if ([plot isKindOfClass:[CPTBarPlot class]]) {
        if ((fieldEnum == CPTBarPlotFieldBarTip) && (index < [self.weeklyStat count])) {
            BHDailyStat *dayStat = [self.weeklyStat objectAtIndex:index];
            if ([plot.identifier isEqual:CPDTickerSymbolGOOG]) {
                // Pour les autres jours
                if (index == self.currentWeeday) {
                    return 0;
                } else {
                    return [NSNumber numberWithInt:(int)[dayStat.clients integerValue]];
                }
//                return [NSNumber numberWithUnsignedInteger:index*10];
            } else if ([plot.identifier isEqual:CPDTickerSymbolAAPL] == YES) { // Bare for real time clue of current day
                // For today
                if (index == self.currentWeeday) {
                    return [NSNumber numberWithInt:(int)[dayStat.clients integerValue]];
                } else {
                    return 0;
                }
            } else if ([plot.identifier isEqual:CPDTickerSymbolLACROIX] == YES) {
                if (index == self.currentWeeday) {
                    return occupancy;
                } else {
                    return 0;
                }
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
                    return [NSNumber numberWithInt:(int)[hourlyStat.clients integerValue]];
                } else if ([plot.identifier isEqual:CPDTickerSymbolLACROIX] == YES) {
                    return occupancy;
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
        NSNumber *xx = [NSNumber numberWithInt:0];
        NSNumber *yy = [NSNumber numberWithInt:0];
        NSArray *anchorPoint = [NSArray arrayWithObjects:xx, yy, nil];
        self.priceAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
    }
    
    // 4 - Create number formatter, if needed
    static NSNumberFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setMaximumFractionDigits:2];
    }
    
    // 5 - Create text layer for annotation
    NSString *occupancyValue = [NSString stringWithFormat:@"%@%%", price];
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:occupancyValue style:style];
    self.priceAnnotation.contentLayer = textLayer;
    
    // 6 - Get plot index based on identifier
    NSInteger plotIndex = 0;
    if ([plot.identifier isEqual:CPDTickerSymbolGOOG] == YES) {
        plotIndex = 0;
    } else if ([plot.identifier isEqual:CPDTickerSymbolLACROIX] == YES) {
        plotIndex = 1;
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
    self.selectedDayIndex = (int)index;
    [self initHourlyStatPlotForDay:(int)index];

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
        contribViewController.locationStat = self.locationStat;
    }
}


- (IBAction)contribute:(UIBarButtonItem *)sender {
    
}
@end
