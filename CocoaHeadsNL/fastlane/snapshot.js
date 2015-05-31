#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

target.delay(3)
captureLocalizedScreenshot("0-LandingScreen")

target.frontMostApp().tabBar().buttons()["Events"].tap();
captureLocalizedScreenshot("1-Events")
target.frontMostApp().mainWindow().tableViews()[0].tap();
captureLocalizedScreenshot("2-EventDetail")

target.frontMostApp().tabBar().buttons()["Jobs"].tap();
captureLocalizedScreenshot("3-Jobs")
target.frontMostApp().mainWindow().collectionViews()[0].cells()[0].tap();
captureLocalizedScreenshot("4-JobsDetail")

target.frontMostApp().tabBar().buttons()["Companies"].tap();
captureLocalizedScreenshot("5-Companies")
target.frontMostApp().mainWindow().collectionViews()[0].cells()[0].tap();
captureLocalizedScreenshot("6-CompaniesDetail")

