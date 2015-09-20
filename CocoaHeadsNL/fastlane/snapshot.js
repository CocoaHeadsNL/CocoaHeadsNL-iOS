#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

target.delay(3)
target.frontMostApp().tabBar().buttons()["Events"].tap();
target.delay(3)
captureLocalizedScreenshot("0-Events")

target.frontMostApp().tabBar().buttons()["Jobs"].tap();
target.delay(3)
captureLocalizedScreenshot("1-Jobs")

target.frontMostApp().tabBar().buttons()["Companies"].tap();
target.delay(3)
captureLocalizedScreenshot("2-Companies")

target.frontMostApp().tabBar().buttons()["About"].tap();
target.delay(3)
captureLocalizedScreenshot("3-About")

