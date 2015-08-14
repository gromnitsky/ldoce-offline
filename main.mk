pp-%:
	@echo "$(strip $($*))" | tr ' ' \\n

.DELETE_ON_ERROR:

src := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: help
help:
	@:$(info $(help))

apk.db := ldoce.sqlite3
apk.unpack.dir = apk
apk.new := ldoce-offline-1.3.apk

define help :=
Required CL params:

APK=file.apk

Targets:

unpack		decompile '$(APK)'
db		extract a db into '$(apk.db)'
patch		patch '$(apk.db)'
pack		create '$(apk.new)'
veriry		check '$(apk.new)'
fetch		download ext. resources

$ make db patch pack APK=my.apk
endef

$(if $(APK),,$(error APK var is empty))
$(if $(filter $(src),$(CURDIR)/),$(error do not run Make in src dir),)

.PHONY: unpack
unpack: $(apk.unpack.dir)

$(apk.unpack.dir): $(APK)
	rm -rf $@
	apktool d $< -o $@
	rm apk/original/META-INF/PEARSON.*

.PHONY: db
db: $(apk.db)

$(apk.db): $(apk.unpack.dir)
	cat $</assets/pearson5.* > $@

.PHONY: patch
patch: $(wildcard $(src)/patch/*.patch)
	@for idx in $^; do \
		patch --binary -p0 < $$idx; \
	done

.PHONY: diff
diff:
	diff -aru --binary apk.orig apk > 1.patch; :
	splitdiff -ad 1.patch
	rm 1.patch
	mv *.patch $(src)/patch/

$(apk.new): $(apk.unpack.dir)
	apktool b $< -o $@
	jarsigner -verbose -sigalg MD5withRSA -digestalg SHA1 -keystore ~/.android/debug.keystore -storepass android -keypass android $@ androiddebugkey

.PHONY: pack
pack: $(apk.new)

.PHONY: verify
verify: $(apk.new)
	jarsigner -verify -certs $<

.PHONY: fetch
fetch: $(apk.db)
	$(src)/ldoce-db -u $< | $(src)/ldoce-db --fetch
