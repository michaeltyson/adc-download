adc-download
============

A script to perform resumable downloads from the Apple Developer Center

Safari's resume facility is just awful -- it'll randomly restart downloads from the beginning, clobbering anything that's already been downloaded, and the resume button will frequently disappear entirely and mysteriously from the downloads window.  And if the session has expired, it'll cause all kinds of havoc.

Anyone downloading the gazillion-gb iOS/Mac SDK + XCode on a slow and/or expensive connection will know the sheer fisticuffs-inspiring irritation this creates -- speaking personally, living on a mobile broadband connection that's usually changed at £3 per gig and often runs about as fast as I could send the data via carrier pigeon, this usually makes me want to storm Cupertino with a pitchfork.

Thus, this script.

It'll ask for your Apple ID and password, and store it in the keychain for you, and it'll resume from the current working directory.

Chuck it somewhere like `/usr/local/bin`, make sure it's executable (`chmod +x /usr/local/bin/adc_download.sh`) and call it from Terminal like:

`adc_download.sh https://developer.apple.com/devcenter/download.action?path=/Developer_Tools/xcode_4_gm_seed/xcode_4_gm_seed_.dmg`

If you've already started the download in Safari, just grab the partially-downloaded file from within the *.download* package Safari creates.

[Resuming ADC downloads (‘cos Safari sucks)](http://atastypixel.com/blog/resuming-adc-downloads-cos-safari-sucks/)