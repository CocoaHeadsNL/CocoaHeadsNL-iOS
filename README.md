#About this app

Why an app? We're a community of mostly mobile developers so could you imagine we wouldn't? 
Why opensource it? We are a non-profit organisation and organise our monthly meetup to share ideas, learn from each other and meet other developers. Keeping it closed seemed out of place.

How do we see this working?
We used the opensource license to promote sharing for non-commercial use and educational purposes. In case you have any ideas, suggestions or additions, just get in contact so you can see what is happening already. We still got some things on our wishlist. Our email: foundation@cocoaheads.nl

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

##Parse command-line tool
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

##Contributions
Please note that we consider all ownership of conrtibutions made to this project to automatically transfer to Stichting CocoaHeadsNL. If you do not agree to this, do not contribute. Also note, any contributions we receive should be allowed to be transfered to Stichting CocoaHeadsNL. If you make contributions and at a later stage ownership of said contributions are not lawfully transfered to our possesion, you as a contributor are considered liable for this. Please note, that the before statement sounds harsh, but basicly if you write original code on your own or legally alloted time and use open source components with compatible licenses: You are perfectly fine. As maintainers of this project we do actively try and guide contributors through these hurdles, we want to work with our community to make this project a great success.

All contributors to this project are listed here: https://github.com/CocoaHeadsNL/CocoaHeadsNL-iOS/graphs/contributors
