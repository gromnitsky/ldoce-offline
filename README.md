# ldoce-offline

A small hack to force an android version of Longman Dictionary of
Contemporary English (LDOCE) to work offline. The audio edition of the
dictionary looks up for headwords pronunciations & recorded examples
in an external web server that sometimes struggles to keep up w/
requests.

We can extract all the entries from the LDOCE app db; parse their
broken xml; search for .mp3/.jpg filenames; download all external
resources; decode the dex files; replace `http://` links w/ `file://`;
rebuild the apk.

## Sine qua non

* LDOCE 1.3 apk (yes, an old one from around 2012; the app version
  must be exactly 1.3)
* Ruby 2+
* jdk 1.7+
* Android SDK Tools
* [apktool](http://ibotpeaches.github.io/Apktool/install/)
* Linux (tested on Fedora 22)

## Downloading mp3 & jpeg

Create an umbrella directory:

	$ mkdir ldoce-offline
	$ cd !$
	$ git clone https://github.com/gromnitsky/ldoce-offline

**Don't run any commands under the cloned source directory.** Do this
instead:

	$ mkdir _out
	$ cd !$
	$ cp /where/my/apk/file/is/com.mobifusion.android.ldoce5.3.apk .

Install required gems:

	$ ln -s ../ldoce-offline/Gemfile* .
	$ rvm gemset use ldoce
	$ bundle install

Run the downloader:

	$ make -f ../ldoce-offline/main.mk APK=com.mobifusion.android.ldoce5.3.apk fetch

It'll take a loooong time. In any moment you can press
<kbd>Ctrl-C</kbd> & rerun the command later--the script won't fetch the same
file twice.

## Copying files to sd card

SD cards in Android phones are usually formatted w/ the FAT32
filesystem that won't fly in our case for
[FAT32 has a limitation](http://superuser.com/questions/446282/max-files-per-directory-on-ntfs-vol-vs-fat32)
of 2<sup>16</sup> files per directory. (I hit the ceiling around 21844.)

Thus we need to create another partition on the sdcard & format it w/
ext3 or ext4 filesystems & automount that partition during the
boot. As I was already using
[Link2SD](http://www.link2sd.info/description) that requires to have a
separate ext3 partition for it to work properly I chose `/data/sdext2`
as an umbrella directory for the downloaded LDOCE assets.

E.g. copy `longmandictionariesusa` directory (2.1GB, 163,423 files) to
`/data/sdext2` directory on your device. This path is hardcoded &
shoud be world-readable (`0755` is fine). If you have plenty of
internal space in the phone, replace `/data/sdext2/` strings to the
desired location in
`patch/apk_smali_com_mobifusion_android_data_ConverterCss.smali.patch`
file before...

## Generating a new APK

(While still in `_out` directory)

	$ make -f ../ldoce-offline/main.mk APK=com.mobifusion.android.ldoce5.3.apk pack

`ldoce-offline-1.3.apk` file should appear.

If you don't have an Android debug keystore
`~/.android/debug.keystore` & a build step fails,
[look here](http://stackoverflow.com/questions/8576732) how to
generate one.

Finally, install a new apk into your device:

	$ adb install ldoce-offline-1.3.apk

You must uninstall the original LDOCE app before installing this one.

## License

MIT.
