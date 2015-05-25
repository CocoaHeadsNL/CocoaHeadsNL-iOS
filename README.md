#Before running the CloudCode
Please perform these steps:

```bash
cp CocoaHeadsNL/CloudCode/config/global.json.template CocoaHeadsNL/CloudCode/config/global.json
```
Now replace the placeholders for PARSE_APPLICATION_ID and PARSE_MASTER_KEY in the newly created global.json with their respective values from parse.com

```bash
cp CocoaHeadsNL/CocoaHeadsNL/ParseConfig-template.plist CocoaHeadsNL/CocoaHeadsNL/ParseConfig.plist

Now replace the placeholders for PARSE_APPLICATION_ID and PARSE_CLIENT_KEY in the newly created ParseConfig.plist with their respective values from parse.com
```
**Take special care to put the client and master key in their respective locations. Leaking the masterkey is very bad.**

Once done with these steps, please run pod install in the directory containing the Podfile.

##Parse comming-line tool
To build this project you need to have the parse.com commandline tool installed:
```bash
curl -s https://www.parse.com/downloads/cloud_code/installer.sh | sudo /bin/bash
```
This will allow you to upload symbolication information to parse.com for your developer builds.

More info: [https://www.parse.com/docs/cloud_code_guide](https://www.parse.com/docs/cloud_code_guide)

##Project structure
CocoaHeadsNL contains two important components.

- The iOS app implementation
- The Parse CloudCode related "stuff"

Everything CloudCode is in the folder CloudCode. This folder needs to remain there for the Symbolication uploading to work. All other files and directories are related to the iOS app.

Minimal deployment target of the app is 8.1