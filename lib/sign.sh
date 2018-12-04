# !/bin/bash
SOURCEIPA="$1"
DEVELOPER="$2"
MOBILEPROV="$3"
TARGET="$4"
KEYCHAIN="$5"
BUNDLE="$6"

# extracting ipa file
echo "extracting the IPA"
unzip -qo "$SOURCEIPA" -d extracted

# get app name
APPLICATION=$(ls extracted/Payload/)

# copy the new mobileprovision file
cp "$MOBILEPROV" "extracted/Payload/$APPLICATION/embedded.mobileprovision"

echo "Resigning with certificate: $DEVELOPER"

# change the bundle id
if [[ "$BUNDLE" != 'null.null' ]]; then
   echo "Changing BundleID with : $BUNDLE"
   /usr/libexec/PlistBuddy -c "Set:CFBundleIdentifier $BUNDLE" "extracted/Payload/$APPLICATION/Info.plist"
fi

# get the new entitlements content
echo "Generate entitlements file"
security cms -D -i "extracted/Payload/$APPLICATION/embedded.mobileprovision" > t_entitlements_full.plist
/usr/libexec/PlistBuddy -x -c 'Print:Entitlements' t_entitlements_full.plist > t_entitlements.plist

# get all should be resigned binary file
echo "Find all resigned file"
find -d extracted  \( -name "*.app" -o -name "*.appex" -o -name "*.framework" -o -name "*.dylib" \) > directories.txt

var=$((0))
while IFS='' read -r line || [[ -n "$line" ]]; do
  echo "Processing $line"
  entitlements_path="t_entitlements.plist"

  # change the extension bundle id
  if [[ "$BUNDLE" != 'null.null' ]] && [[ "$line" == *".appex"* ]]; then
     echo "Changing .appex BundleID with : $BUNDLE.extra$var"
     /usr/libexec/PlistBuddy -c "Set:CFBundleIdentifier $BUNDLE.extra$var" "$line/Info.plist"
     var=$((var+1))
  fi

  # replace all *.framework entitlement content
  if [[ "$line" == *".framework"* ]]; then
    BINARYNAME=$(/usr/bin/basename "$line" ".framework")
    entitlements_path="${BINARYNAME}_entitlements.plist"
    codesign -d --entitlements :- "$line" > $entitlements_path 2&>/dev/null
  fi

  # todo: force replace the cert type(custom biz code, not common code), now only support macOS
  app_json_file="$line/app_factory/app/app.json"
  if [ -f "$app_json_file" ]; then
    JQBASEPATH=$(/usr/bin/dirname "$0")
    JQPATH="${JQBASEPATH}/jq"
    chmod a+x $JQPATH
    temp_app_json_file="app.json"
    mv $app_json_file $temp_app_json_file
    $JQPATH '.ios.cert_type = "app_store"' -c $temp_app_json_file > $app_json_file
    rm $temp_app_json_file
  fi

  # execute regsign action
  /usr/bin/codesign --continue -f -s "$DEVELOPER" --entitlements "$entitlements_path" --keychain "$KEYCHAIN" "$line"
done < directories.txt

# zip the signed files
echo "Creating the Signed IPA"
cd extracted
zip -qry ../extracted.ipa *
cd ..
mv extracted.ipa "$TARGET"

# clean workspace
rm -rf "extracted"
rm directories.txt
rm t_entitlements.plist
rm t_entitlements_full.plist
rm *"_entitlements.plist"

echo "Finish resign. Output:$TARGET"