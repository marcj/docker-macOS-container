sudo mount -uw /

rm -rf /System/Library/Extensions/AMDRadeon*
rm -rf /System/Library/Extensions/GeForce*
rm -rf /System/Library/Desktop\ Pictures/*
find /System/Library/Templates/Data/System/Library/Speech -name PCMWave -exec rm -rf {} \;

rm -rf /System/Library/Screen\ Savers/*.saver
rm -rf /private/var/db/dyld

xcrun simctl erase all
