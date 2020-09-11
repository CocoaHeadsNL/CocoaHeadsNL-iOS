We create the gpg files by running commands like...
```
gpg --symmetric --cipher-algo AES256 CocoaHeadsNL-AppStore.mobileprovision
gpg --symmetric --cipher-algo AES256 CocoaHeadsNL-AppStore-Item-Service-Extension.mobileprovision
gpg --symmetric --cipher-algo AES256 CocoaHeadsNL-AppStore-Item-Notification.mobileprovision
gpg --symmetric --cipher-algo AES256 CocoaHeadsNL-AppStore-General-Notification.mobileprovision
gpg --symmetric --cipher-algo AES256 AppStoreCertificates.p12
```

The password on the P12 file is the same as the password used to perform the encryption. The password is also stored on Github as a secret in the env var `PROVISIONING_PASSWORD`.
