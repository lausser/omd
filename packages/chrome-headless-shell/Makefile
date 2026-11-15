include ../../Makefile.omd

# headless chromium used by thruk to create pdf reports and grafana images.
# Thruk finds it through THRUK_BROWSER, see skel/etc/profile.d/thruk_browser.sh
# and https://www.thruk.org/documentation/faq.html#chromium

NAME     = chrome-headless-shell
SHELL    = /bin/bash
VERSION  = 147.0.7727.117
ifeq ($(DISTRO_CODE),el7)
  VERSION = 121.0.6100.0 # last version which runs on rhel 7
endif
ARCH     = $(shell uname -m)
DIR      = chrome-headless-shell-linux64
ZIP      = $(NAME)-$(VERSION)-linux64.zip
URL      = https://storage.googleapis.com/chrome-for-testing-public/$(VERSION)/linux64/chrome-headless-shell-linux64.zip

.PHONY: skel

# there is no chrome-headless-shell for linux aarch64, the system chromium is used there
build:
ifeq ($(ARCH),x86_64)
	rm -rf $(DIR)
	test -s $(ZIP) || curl -fL --retry 3 -o $(ZIP).tmp $(URL) || wget -O $(ZIP).tmp $(URL)
	test -s $(ZIP) || mv $(ZIP).tmp $(ZIP)
	unzip -q $(ZIP)
	test -x $(DIR)/chrome-headless-shell
else
	CHROMIUM=$$(which chromium-browser chromium 2>/dev/null | head -n 1); \
	test -n "$$CHROMIUM" || { echo "no chromium package installed on this $(ARCH) build host"; exit 1; }
endif

install:
ifeq ($(ARCH),x86_64)
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/$(NAME)
	cp -rp $(DIR)/. $(DESTDIR)$(OMD_ROOT)/lib/$(NAME)/
	chmod -R a+rX $(DESTDIR)$(OMD_ROOT)/lib/$(NAME)
endif

skel:
	mkdir -p $(SKEL)/etc/profile.d
ifeq ($(ARCH),x86_64)
	echo 'export THRUK_BROWSER=$$OMD_ROOT/lib/$(NAME)/$(NAME)' > $(SKEL)/etc/profile.d/thruk_browser.sh
else
	CHROMIUM=$$(which chromium-browser chromium 2>/dev/null | head -n 1); \
	test -n "$$CHROMIUM" || exit 1; \
	echo "export THRUK_BROWSER=$$CHROMIUM" > $(SKEL)/etc/profile.d/thruk_browser.sh
endif

clean:
	rm -rf $(DIR) $(ZIP) $(ZIP).tmp
	rm -f skel/etc/profile.d/thruk_browser.sh
