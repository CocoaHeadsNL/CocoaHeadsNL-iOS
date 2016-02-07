Code and instructions derived from [Apple Sample code](https://developer.apple.com/library/prerelease/ios/samplecode/CloudAtlas/Introduction/Intro.html#//apple_ref/doc/uid/TP40014599).

## Install dependencies

Our script uses the npm module *node-fetch* and the *CloudKit JS* library. Install them by running the following
commands from the same directory as this README.
```
npm install
npm run-script generate-config
npm run-script install-cloudkit-js
```

## Generate a private key

If you are using a Mac, you already have OpenSSL installed and you can generate a private key with this command (make
sure you are in the same directory as this README).
```
openssl ecparam -name prime256v1 -genkey -noout -out eckey.pem
```
This will create the file `eckey.pem`. *Do not publish this file!*

## Create a Server-to-Server key in CloudKit Dashboard

In [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard) select the CocoaHeadsNL container and navigate to
`API Access -> Server-to-Server Keys`. Copy the public key in the output of this command:
```
openssl ec -in eckey.pem -pubout
```

and paste it into the *Public Key* text field of the new key. Hit *Save* and the *Key ID* attribute will get populated.
Copy this ID and fill in the **keyID** property in `config.js`.

## Make sure all placeholders in config.js are replaced with valid values.

- github username
- github access token
- Meetup API Key
- Server-2-server CloudKit key

See config.js for more information.

## Run the script

```
node index.js
```
