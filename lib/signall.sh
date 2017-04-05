# !/bin/bash
signscript="/Users/arida/Develop/source/opensource/ios-ipa-resign/sign.sh"
ipasourcefolder="/Users/arida/Develop/source/opensource/ios-ipa-resign/orig"
ipadestfolder="/Users/arida/Develop/source/opensource/ios-ipa-resign/signed/"

developer1="iPhone Distribution: Fujian Tianquan Education Technology Limited (D89QP4KXMX)"
mobileprovision1="/Users/arida/Develop/source/opensource/ios-ipa-resign/component_test_distribution_adhoc.mobileprovision"

bundleid="com.nd.sdp.component.debug" #use null.null if you want to use the default app bundleid


cd $ipasourcefolder
find -d . -type f -name "*.ipa"> files.txt
while IFS='' read -r line || [[ -n "$line" ]]; do
	filename=$(basename "$line" .ipa)
	echo "Ipa: $filename"
	#_dev1_______
	output=$ipadestfolder$filename
	output+="_signed_dev1.ipa"
	"$signscript" "$line" "$developer1" "$mobileprovision1" "$output" "$bundleid"
done < files.txt
rm files.txt
