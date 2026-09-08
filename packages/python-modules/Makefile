include ../../Makefile.omd

NAME       = python-modules
SHELL      = /bin/bash
FREETDS    = $(shell readlink -m ../freetds/tmpinstall$(OMD_ROOT))
PYTHON_V   = $(shell python3 --version 2>&1 | cut -d' ' -f2)

DEPENDS  = freetds

# This is where the python modules are going to be installed to
LOCALPYTHONDIR=$(DESTDIR)$(OMD_ROOT)/lib/python
BUILDDEST=$(shell pwd)/dest
WHEELSDIR=$(shell pwd)/wheels
SRCDIR=$(shell pwd)/src

UV_VERSION=0.12.10
UV=$(shell pwd)/bin/uv
UV_PIP=$(UV) pip
UV_BUILD=$(UV) build --wheel --no-build-isolation
PIP=python3 -m pip

HAS_PYTHON_307_OR_NEWER := $(shell \
    required_version="3.7.0"; \
    if [ $$(echo -e "$(PYTHON_V)\n$$required_version" | sort -V | head -n1) = "$$required_version" ]; then \
        echo "true"; \
    else \
        echo "false"; \
    fi \
)
HAS_PYTHON_312_OR_NEWER := $(shell \
    required_version="3.12.0"; \
    if [ $$(echo -e "$(PYTHON_V)\n$$required_version" | sort -V | head -n1) = "$$required_version" ]; then \
        echo "true"; \
    else \
        echo "false"; \
    fi \
)

# BASE packages - build toolchain (downloaded as wheels)
BASE_DL = packaging==21.3 setuptools==59.6.0 wheel==0.37.1 pip==21.3.1 pyparsing==3.0.8

# MODULES that can be downloaded as wheels from PyPI
MODULES_DL = \
	semantic-version==2.10.0 \
	tomli==1.2.3 \
	flit-core==3.5.1 \
	typing-extensions==3.10.0.2 \
	setuptools-scm==6.4.2 \
	setuptools-rust==1.1.2 \
	setuptools-git==1.2 \
	Cython==0.29.32 \
	ply==3.11 \
	charset-normalizer==2.1.1 \
	idna==3.4 \
	urllib3==1.26.13 \
	certifi==2025.1.31 \
	chardet==3.0.4 \
	requests==2.27.1 \
	MarkupSafe==2.0.1 \
	Jinja2==3.0.3 \
	lml==0.1.0 \
	pyexcel-io==0.6.6 \
	texttable==1.6.7 \
	pyexcel==0.7.0 \
	defusedxml==0.7.1 \
	pyexcel-ods==0.6.0 \
	et-xmlfile==1.1.0 \
	openpyxl==3.0.10 \
	pyexcel-xlsx==0.6.0 \
	six==1.16.0 \
	paramiko==1.18.5 \
	PyYAML==6.0 \
	pysmi==0.3.4 \
	pyasn1==0.4.8 \
	pysnmp==4.4.12 \
	prometheus-client==0.15.0 \
	simplejson==3.18.0 \
	resolvelib==0.8.1 \
	decorator==4.4.0 \
	jsonpath-ng==1.5.3 \
	pymssql==2.2.7

# MODULES that MUST be built from source (no manylinux wheels on PyPI for py36)
MODULES_BUILD = \
	mysqlclient==2.1.1 \
	pysmbc==1.0.25.1 \
	pyvmomi==8.0.3.0.1 \
	redfish==3.1.8 \
	psutil==5.9.4 \
	gearman3==0.2.1 \
	nagiosplugin==1.3.3 \
	omdnotificationforwarder==4.4 \
	omdeventhandler==2.2 \
	monplugin==0.6.3 \
	checkvsphere==0.3.30 \
	odfpy==1.4.1 \
	pycryptodomex==3.16.0

# Overrides for Python 3.7+
OVERRIDES_37 = certifi==2026.4.22 Jinja2==3.1.6 pycryptodomex==3.23.0

# Overrides for Python 3.12+
OVERRIDES_312 = \
	setuptools==83.0.0 \
	wheel==0.46.3 \
	pip==26.2.1 \
	packaging==25.0 \
	setuptools-scm==8.1.0 \
	setuptools-rust==1.10.2 \
	Cython==3.0.11 \
	PyYAML==6.0.2 \
	pymssql==2.3.1 \
	paramiko==3.5.0 \
	requests==2.33.0 \
	urllib3==2.7.0 \
	mysql-connector-python==9.5.0 \
	idna==3.18 \
	pyasn1==0.6.4 \
	pyparsing==3.3.2 \
	flit-core==3.12.0

export PIP_ROOT_USER_ACTION=ignore

# Helper functions
define APPLY_OVERRIDES
$(shell \
	for pkg in $(1); do \
		name=$$(echo $$pkg | sed 's/==.*//'); \
		found=false; \
		for ovr in $(2); do \
			oname=$$(echo $$ovr | sed 's/==.*//'); \
			if [ "$$oname" = "$$name" ]; then \
				echo $$ovr; \
				found=true; \
				break; \
			fi; \
		done; \
		if [ "$$found" = "false" ]; then \
			echo $$pkg; \
		fi; \
	done
)
endef


# Install wheels
define INSTALL_WHEELS
	$(PIP) install --no-cache-dir --no-index --no-deps --find-links=$(WHEELSDIR) --target=$(BUILDDEST) $(WHEELSDIR)/*.whl
endef

# Build wheel from source
define BUILD_WHEEL
	echo "** Building $(1) from source **"; \
	name=$$(echo $(1) | sed 's/==.*//'); \
	version=$$(echo $(1) | sed 's/.*==//'); \
	src_file=$$(ls $(SRCDIR)/$${name}-$${version}.tar.gz 2>/dev/null | head -1); \
	if [ -z "$$src_file" ]; then src_file=$$(ls $(SRCDIR)/$${name}-$${version}.tgz 2>/dev/null | head -1); fi; \
	if [ -z "$$src_file" ]; then src_file=$$(ls $(SRCDIR)/$${name//-/_}-$${version}.tar.gz 2>/dev/null | head -1); fi; \
	if [ -z "$$src_file" ]; then src_file=$$(ls $(SRCDIR)/$${name//-/_}-$${version}-*.whl 2>/dev/null | head -1); fi; \
	if [ -z "$$src_file" ]; then src_file=$$(ls $(SRCDIR)/*$${name}*$${version}* 2>/dev/null | head -1); fi; \
	if [ -z "$$src_file" ]; then name_lc=$$(echo $$name | tr '[:upper:]' '[:lower:]'); src_file=$$(ls $(SRCDIR)/$${name_lc}-$${version}.tar.gz 2>/dev/null | head -1); fi; \
	if [ -z "$$src_file" ]; then src_file=$$(ls $(SRCDIR)/$${name_lc//-/_}-$${version}.tar.gz 2>/dev/null | head -1); fi; \
	if [ -z "$$src_file" ]; then src_file=$$(ls $(SRCDIR)/$${name_lc//-/_}-$${version}-*.whl 2>/dev/null | head -1); fi; \
	if [ -z "$$src_file" ]; then src_file=$$(ls $(SRCDIR)/*$${name_lc}*$${version}* 2>/dev/null | head -1); fi; \
	if [ -n "$$src_file" ] && [ -f "$$src_file" ]; then \
		echo "  Using source: $$src_file"; \
		if [[ "$$src_file" == *.whl ]]; then \
			cp "$$src_file" $(WHEELSDIR)/; \
		elif [[ "$(1)" =~ pymssql ]]; then \
			if [ `uname -m` = 'armv7l' ]; then export PYMSSQL_BUILD_WITH_BUNDLED_FREETDS=1; else export PYMSSQL_BUILD_WITH_BUNDLED_FREETDS=0; fi; \
			LINK_KRB5=NO CFLAGS="${CFLAGS} -I $(FREETDS)/include -L $(FREETDS)/lib" $(UV_BUILD) --out-dir=$(WHEELSDIR) --find-links=$(WHEELSDIR) "$$src_file"; \
		elif [[ "$(1)" =~ tomli ]]; then \
			(cd $(SRCDIR) && (tar zxf "$$(basename $$src_file)" --no-same-owner || :) && cd ./tomli-*/ && python3 -c 'from setuptools import setup; setup(name="tomli", packages=["tomli"], package_data={"": ["*"]}, version="1.2.3")' bdist_wheel); \
			mv ./src/tomli-*/dist/*.whl $(WHEELSDIR); rm -rf ./src/tomli-*/; \
		else \
			$(UV_BUILD) --out-dir=$(WHEELSDIR) --no-index --find-links=$(WHEELSDIR) "$$src_file"; \
		fi; \
	else \
		echo "ERROR: source not found for $(1) in $(SRCDIR)"; \
		exit 1; \
	fi
endef

build:
	mkdir -p $(WHEELSDIR) $(BUILDDEST)
	export PYTHONPATH=$(BUILDDEST):$$PYTHONPATH; \
	export CFLAGS="${CFLAGS} -std=c99"; \
	unset http_proxy https_proxy ftp_proxy; \
	set -e; \
	\
	# Step 1: Apply overrides \
	BASE_DL_OVERRIDES=$$(for pkg in $(BASE_DL); do name=$$(echo $$pkg | sed 's/==.*//'); found=false; for ovr in $(if $(filter true,$(HAS_PYTHON_312_OR_NEWER)),$(OVERRIDES_312),$(if $(filter true,$(HAS_PYTHON_307_OR_NEWER)),$(OVERRIDES_37),)); do oname=$$(echo $$ovr | sed 's/==.*//'); if [ "$$oname" = "$$name" ]; then echo $$ovr; found=true; break; fi; done; if [ "$$found" = "false" ]; then echo $$pkg; fi; done); \
	MODULES_DL_OVERRIDES=$$(for pkg in $(MODULES_DL); do name=$$(echo $$pkg | sed 's/==.*//'); found=false; for ovr in $(if $(filter true,$(HAS_PYTHON_312_OR_NEWER)),$(OVERRIDES_312),$(if $(filter true,$(HAS_PYTHON_307_OR_NEWER)),$(OVERRIDES_37),)); do oname=$$(echo $$ovr | sed 's/==.*//'); if [ "$$oname" = "$$name" ]; then echo $$ovr; found=true; break; fi; done; if [ "$$found" = "false" ]; then echo $$pkg; fi; done); \
	MODULES_BUILD_OVERRIDES=$$(for pkg in $(MODULES_BUILD); do name=$$(echo $$pkg | sed 's/==.*//'); found=false; for ovr in $(if $(filter true,$(HAS_PYTHON_312_OR_NEWER)),$(OVERRIDES_312),$(if $(filter true,$(HAS_PYTHON_307_OR_NEWER)),$(OVERRIDES_37),)); do oname=$$(echo $$ovr | sed 's/==.*//'); if [ "$$oname" = "$$name" ]; then echo $$ovr; found=true; break; fi; done; if [ "$$found" = "false" ]; then echo $$pkg; fi; done); \
	\
	# Step 2: Build all packages from src/ (offline) \
	echo "=== Building all packages from src/ ==="; \
	for pkg in $$BASE_DL_OVERRIDES $$MODULES_DL_OVERRIDES $$MODULES_BUILD_OVERRIDES; do \
		$(call BUILD_WHEEL,$$pkg); \
	done; \
	\
	# Step 3: Install all packages \
	echo "=== Installing all packages ==="; \
	$(call INSTALL_WHEELS)

install:
	mkdir -p $(LOCALPYTHONDIR)
	rsync -a $(BUILDDEST)/. $(LOCALPYTHONDIR)/.
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/
	mv $(LOCALPYTHONDIR)/bin/check_vsphere $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/check_vsphere

skel:

clean:
	rm -rf dest
	rm -rf wheels

check_files:
	@echo "list of for orphaned source files:"
	@for F in $$(ls -1 src/*); do \
		F=$$(echo $$F | sed -e 's%src/%%'); \
		if ! grep $$F Makefile >/dev/null 2>&1; then \
			echo "- orphaned: $$F"; \
		fi; \
	done
	@echo "list of for referenced source files:"
	@for F in $$(grep -P '^(BASE|MODULES|OVERRIDES)' Makefile | awk '{ print $$3 }' | grep -v ^$$); do \
		if ! test -e src/$$F >/dev/null 2>&1; then \
			echo "- missing: $$F"; \
		fi; \
	done

upstream:
	@mkdir -p bin
	@echo "==> Downloading uv $(UV_VERSION) into bin/uv"; case $$(uname -m) in x86_64)  UV_TARGET=x86_64-unknown-linux-gnu;; aarch64) UV_TARGET=aarch64-unknown-linux-gnu;; armv7l)  UV_TARGET=armv7-unknown-linux-gnueabihf;; *) echo "unsupported arch '$$(uname -m)' for uv"; exit 1;; esac; curl -fsSL "https://github.com/astral-sh/uv/releases/download/$(UV_VERSION)/uv-$${UV_TARGET}.tar.gz" -o /tmp/uv-dl.tgz; tar -xzf /tmp/uv-dl.tgz -C /tmp; install -m 0755 /tmp/uv-$${UV_TARGET}/uv bin/uv; rm -rf /tmp/uv-dl.tgz /tmp/uv-$${UV_TARGET}; bin/uv --version
	set -e; cd src && \
	export WHEELSDIR=$$(realpath ../wheels); \
	for M in $(MODULES_DL) $(MODULES_BUILD); do \
	    MODULE=$$(echo $$M | sed -e 's/.tar.gz//g' -e 's/.zip//g' -e 's/==.*//'); \
	    VERSION=$$(echo $$M | sed "s/^.*==//"); \
	    $(PIP) download --find-links=$${WHEELSDIR} --no-binary :all: --progress-bar off --no-deps -d . $${MODULE}==$${VERSION}; \
	done
