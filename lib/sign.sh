# !/bin/bash
SOURCEIPA="$1"
DEVELOPER="$2"
MOBILEPROV="$3"
TARGET="$4"
KEYCHAIN="$5"
BUNDLE="$6"

echo "extracting the IPA"

unzip -qo "$SOURCEIPA" -d extracted

APPLICATION=$(ls extracted/Payload/)

cp "$MOBILEPROV" "extracted/Payload/$APPLICATION/embedded.mobileprovision"

echo "Resigning with certificate: $DEVELOPER"

if [[ "$BUNDLE" != 'null.null' ]]; then
   echo "Changing BundleID with : $BUNDLE"
   /usr/libexec/PlistBuddy -c "Set:CFBundleIdentifier $BUNDLE" "extracted/Payload/$APPLICATION/Info.plist"
fi

echo "Generate entitlements file"

security cms -D -i "extracted/Payload/$APPLICATION/embedded.mobileprovision" > t_entitlements_full.plist
/usr/libexec/PlistBuddy -x -c 'Print:Entitlements' t_entitlements_full.plist > t_entitlements.plist
#/usr/libexec/PlistBuddy -c 'Print:application-identifier' t_entitlements.plist > t_entitlements_application-identifier   #save developer application-identifier to file
#/usr/libexec/PlistBuddy -c 'Print:com.apple.developer.team-identifier' t_entitlements.plist > t_entitlements_com.apple.developer.team-identifier  #save com.apple.developer.team-identifier application-identifier to file

echo "Find all resigned file"
find -d extracted  \( -name "*.app" -o -name "*.appex" -o -name "*.framework" -o -name "*.dylib" \) > directories.txt

var=$((0))
while IFS='' read -r line || [[ -n "$line" ]]; do
  echo "Processing $line"
    #/usr/bin/codesign -d --entitlements :-  "$line" > t_entitlements_original.plist    #save original entitlements from the app
    #/usr/libexec/PlistBuddy -x -c 'Import application-identifier t_entitlements_application-identifier' t_entitlements_original.plist #overwrite application-identifier
    #/usr/libexec/PlistBuddy -x -c 'Import com.apple.developer.team-identifier t_entitlements_com.apple.developer.team-identifier' t_entitlements_original.plist #overwrite com.apple.developer.team-identifier
  if [[ "$BUNDLE" != 'null.null' ]] && [[ "$line" == *".appex"* ]]; then
     echo "Changing .appex BundleID with : $BUNDLE.extra$var"
     /usr/libexec/PlistBuddy -c "Set:CFBundleIdentifier $BUNDLE.extra$var" "$line/Info.plist"
     var=$((var+1))
  fi

  entitlements_path="t_entitlements.plist"

  if [[ "$line" == *".framework"* ]]; then
    BINARYNAME=$(/usr/bin/basename "$line" ".framework")
    entitlements_path="${BINARYNAME}_entitlements.plist"
    codesign -d --entitlements :- "$line" > $entitlements_path 2&>/dev/null
  fi
    /usr/bin/codesign --continue -f -s "$DEVELOPER" --entitlements "$entitlements_path" --keychain "$KEYCHAIN" "$line"
done < directories.txt

echo "Creating the Signed IPA"
cd extracted
zip -qry ../extracted.ipa *
cd ..
mv extracted.ipa "$TARGET"

rm -rf "extracted"
rm directories.txt
rm t_entitlements.plist
rm t_entitlements_full.plist
rm *"_entitlements.plist"
#rm t_entitlements_original.plist
#rm t_entitlements_application-identifier
#rm t_entitlements_com.apple.developer.team-identifier

echo "Finish resign. Output:$TARGET"