# iResignApp
Resign iOS app(Support both dynamic library,extension also).

## Usage

```sh
Usage:

  resignapp [--options ...] [input-ipafile]

  -b, --bundleid [BUNDLEID]                   Change the bundleid when repackaging
  -i, --identity [iPhone Distribution:xxx]    Specify Common name to use
  -k, --keychain [KEYCHAIN]                   Specify alternative keychain file
  -m, --mobileprovision [FILE]                Specify the mobileprovision file to use
  -o, --output [APP.ipa]                      Path to the output IPA filename  
      --version                               Show SignApp version
  [input-ipafile]                             Path to the IPA file to resign

Example:

  resignapp -i "iPhone Distribution:xxx" -b "com.xx.test" -k ~/Library/Keychains/login.keychain test-app.ipa
```

Resign an ipa file with specific identity and mobileprovision:

```sh
resignapp -i "iPhone Distribution:xxx" -m "/path/to/appstore.mobileprovision" origin.ipa
```

## API usage

Coming soon.

## Contributing

inspired from [ios-ipa-resign](https://bitbucket.org/xgiovio/ios-ipa-resign)
