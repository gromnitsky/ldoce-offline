# ldoce-offline

A hack to force an android version of Longman Dictionary of
Contemporary English (LDOCE) to work offline. The audio edition of the
dictionary looks up for headwords pronunciations & recorded examples
in an external web server that sometimes struggles to keep up w/
requests.

We can extract all the entries from the LDOCE app db; parse their
broken xml; search for .mp3/.jpg filenames; download all external
resources; decode the dex files; replace `http://` links w/ `file://`;
rebuild the apk.

## Sine qua non

* Ruby 2+
* [LDOCE 1.3 apk](https://play.google.com/store/apps/details?id=com.mobifusion.android.ldoce5)
* Android SDK Tools
* [apktool](http://ibotpeaches.github.io/Apktool/install/)
* Linux (tested on Fedora 22)

## Downloading mp3 & jpeg

Create an umbrella directory:

	$ mkdir ldoce-offline
	$ cd !$
	$ git clone 123

**Don't run any commands under the cloned source directory.** Do this
instead:

	$ mkdir _out
	$ cd !$
	$ cp /where/my/apk/file/is/com.mobifusion.android.ldoce5.3.apk .

Install required gems:

	$ ln -s ../ldoce-offline/Gemfile .
	$ rvm gemset use ldoce
	$ bundle install

Run the downloader:

	$ make -f ../ldoce-offline/main.mk APK=com.mobifusion.android.ldoce5.3.apk fetch

It'll take a loooong time. In any moment you can press
<kbd>Ctrl-C</kbd> & rerun the command later--the script won't fetch the same
file twice.

After that, copy `longmandictionariesusa` directory (2.1GB) to
`/sdcard` directory on your device. (This path is hardcoded.)

## Generating new APK

(in `_out` directory)

	$ make -f ../ldoce-offline/main.mk APK=com.mobifusion.android.ldoce5.3.apk db patch pack

`ldoce-offline-1.3.apk` file should appear.

Install it to your device:

	$ adb install ldoce-offline-1.3.apk

You must remove the original LDOCE app before installing this one.

## License

MIT.
