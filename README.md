#Before running the CloudCode
Please perform these steps:

```bash
cp CocoaHeadsNL/CloudCode/config/global.json.template CocoaHeadsNL/CloudCode/config/global.json

cp CocoaHeadsNL/CocoaHeadsNL/ParseConfig-template.plist CocoaHeadsNL/CocoaHeadsNL/ParseConfig.plist
```

Next replace the following place holders:

- PARSE_APPLICATION_ID
- PARSE_MASTER_KEY
- PARSE_CLIENT_KEY

**Take special care to put the client and master key in their respective locations. Leaking the masterkey is very bad.**