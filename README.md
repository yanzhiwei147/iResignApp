# iResignApp
Resign iOS app.


This code allow you to resign your own ipa assuming that you have:
1) a developer certificate issued by apple and added to your keychain
2) a mobileprovision file

This code allow you to resign your app without using xcode or if you need to add a UDID for development distribution.
This code correctly signs ipas with Frameworks (.framework folders), Plugins (.appex folders), Applications (.app folders).
This code autoincludes entitlements with binaries extracting them from the provided mobileprovision file.

Usage.
This code runs on mac osx
You should already have installed OSX Command Lines Tools
The code is a shell script

Step 1
Change the following variables inside the signall.sh script:


```sh
#!shell

signscript="/path/to/sign.sh"
ipasourcefolder="path/to/ipas/source/folder"
ipadestfolder="/path/to/ipas/destinations/folder/"
developer1="iPhone Developer: xxxxx (xxxxx)"
mobileprovision1="/path/to/mobile/provision"
bundleid="null.null" #use null.null if you want to use the default app bundleid
```

Step 2
make sure that ipasourcefolder and ipadestfolder are writable.
run signall.sh via terminal.
done.

In your destination folder you will have all your ipas signed.


## Additional notes
To change bundleid replace null.null inside the signall.sh script with your custom bundleid.

Restore to null.null to use bundleid included in the ipa.

Using a custom bundleid, if the ipa includes additional apps (for example widget and apple watch), the script will automatically change these bundleids using the following convention : custombundleid.extra1, custombundleid.extra2 and so on.

If you want to change a bundleid for a particular ipa, use only that ipa in the source folder otherwise all ipas present in the source folder will be signed using the same bundleid.

OSX Sierra can output some error during signing.
security: SecPolicySetValue: One or more parameters passed to a function were not valid.
This error maybe is related to some changes by Apple. Ignore it, the signing process is fine.

## Contributing

inspired from [ios-ipa-resign](https://bitbucket.org/xgiovio/ios-ipa-resign)
