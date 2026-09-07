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

# The build is self-contained and must run without internet access:
# every python module is bundled in src/ either as a prebuilt wheel
# (pure python packages) or as a source tarball (C extension packages,
# which have to be built for the target architecture, e.g. armv7l).
# Nothing is downloaded from PyPI at build time.

# install toolchain required to build wheels
BASE =
BASE += pip-21.3.1-py3-none-any.whl
BASE += setuptools-59.6.0-py3-none-any.whl
BASE += wheel-0.37.1-py2.py3-none-any.whl
BASE += packaging-21.3-py3-none-any.whl
BASE += pyparsing-3.0.8-py3-none-any.whl

MODULES =
MODULES += semantic_version-2.10.0-py2.py3-none-any.whl            # setuptools-rust-1.5.2
MODULES += tomli-1.2.3-py3-none-any.whl                           # setuptools_scm-7.0.5 (last version that works with python 3.6)
MODULES += flit_core-3.5.1-py3-none-any.whl                       #  typing_extensions-4.4.0
MODULES += typing_extensions-3.10.0.2-py3-none-any.whl            # setuptools-rust-1.5.2 (last version that works with python 3.6)
MODULES += setuptools_scm-6.4.2-py3-none-any.whl                  # pymssql-2.2.7(<7.0,>=5.0)
MODULES += setuptools_rust-1.1.2-py3-none-any.whl                 # paramiko-2.12.0 deps (last version that works with python 3.6)
MODULES += setuptools_git-1.2-py2.py3-none-any.whl                # pymssql-2.2.7
MODULES += Cython-0.29.32.tar.gz                                  # pymssql-2.2.7
MODULES += ply-3.11-py2.py3-none-any.whl                          # jsonpath_ng-1.5.3, pysmi-0.3.4, pywbem-1.5.0
MODULES += charset_normalizer-2.1.1-py3-none-any.whl              #  requests-2.28.1
MODULES += idna-3.4-py3-none-any.whl                              #  requests-2.28.1
MODULES += urllib3-1.26.13-py2.py3-none-any.whl                   #  requests-2.28.1(<1.27,>=1.21.1)
MODULES += certifi-2025.1.31-py3-none-any.whl                     #  requests-2.28.1
MODULES += chardet-3.0.4-py2.py3-none-any.whl                     #  requests-2.28.1
MODULES += requests-2.27.1-py2.py3-none-any.whl                   # pywbem-1.5.0

# Coshsh
MODULES += MarkupSafe-2.0.1.tar.gz                                # Jinja2-3.1.2
MODULES += Jinja2-3.0.3-py3-none-any.whl

# Coshsh - datasources
MODULES += mysqlclient-2.1.1.tar.gz
MODULES += pymssql-2.2.7.tar.gz
MODULES += mysql_connector_python-8.3.0-py2.py3-none-any.whl
MODULES += lml-0.1.0-py2.py3-none-any.whl                         # pyexcel-0.7.0
MODULES += pyexcel_io-0.6.6-py2.py3-none-any.whl                  # pyexcel-0.7.0
MODULES += texttable-1.6.7-py2.py3-none-any.whl                   # pyexcel-0.7.0
MODULES += pyexcel-0.7.0-py2.py3-none-any.whl
MODULES += defusedxml-0.7.1-py2.py3-none-any.whl                  # odfpy-1.4.1
MODULES += odfpy-1.4.1.tar.gz
MODULES += pyexcel_ods-0.6.0-py2.py3-none-any.whl
MODULES += et_xmlfile-1.1.0-py3-none-any.whl                      # openpyxl-3.0.10
MODULES += openpyxl-3.0.10-py2.py3-none-any.whl
MODULES += pyexcel_xlsx-0.6.0-py2.py3-none-any.whl

# for Ansible
MODULES += six-1.16.0-py2.py3-none-any.whl                        # paramiko-2.12.0, pyvmomi
MODULES += paramiko-1.18.5-py2.py3-none-any.whl
MODULES += PyYAML-6.0.tar.gz

# for snmp simulator and coshsh snmp inventory
MODULES += pysmi-0.3.4-py2.py3-none-any.whl                       # pysnmp-4.4.12
MODULES += pycryptodomex-3.16.0.tar.gz                            # pysnmp-4.4.12
MODULES += pyasn1-0.4.8-py2.py3-none-any.whl                      # pysnmp-4.4.12
MODULES += pysnmp-4.4.12-py2.py3-none-any.whl

# Exporter
MODULES += prometheus_client-0.15.0-py3-none-any.whl

# Plugins
MODULES += simplejson-3.18.0.tar.gz                               # ansible
MODULES += resolvelib-0.8.1-py2.py3-none-any.whl                  # ansible
# for check_json_health
MODULES += decorator-4.4.0-py2.py3-none-any.whl                   # jsonpath_ng-1.5.3
MODULES += jsonpath_ng-1.5.3-py3-none-any.whl
# for check_smb_copy
MODULES += pysmbc-1.0.25.1.tar.gz
# for check_vcenter
MODULES += pyvmomi-8.0.3.0.1.tar.gz                               # check_vsphere
# for check_redfish
MODULES += redfish-3.1.8.tar.gz
# for check_omd
MODULES += psutil-5.9.4.tar.gz

MODULES += gearman3-0.2.1.tar.gz
MODULES += nagiosplugin-1.3.3.tar.gz
# there are prebuilt wheels for omdnotificationforwarder and omdeventhandler
# because "pip wheel ..." would require the hatch build system.
MODULES += omdnotificationforwarder-4.4-py3-none-any.whl
MODULES += omdeventhandler-2.2-py3-none-any.whl

# check_vsphere
MODULES += monplugin-0.6.3.tar.gz                                 # check_vsphere
MODULES += checkvsphere-0.3.30.tar.gz

# override some modules for python 3.07, list could be reevaluated once rhel7-rhel8 support got removed
OVERRIDES=""
ifeq ($(HAS_PYTHON_307_OR_NEWER),true)
OVERRIDES += certifi-2026.4.22-py3-none-any.whl
OVERRIDES += jinja2-3.1.6-py3-none-any.whl
OVERRIDES += pycryptodomex-3.23.0.tar.gz
endif

# override some modules for python 3.12, list could be reevaluated once rhel7 support got removed
ifeq ($(HAS_PYTHON_312_OR_NEWER),true)
OVERRIDES += setuptools-83.0.0-py3-none-any.whl
OVERRIDES += wheel-0.46.3-py3-none-any.whl
OVERRIDES += pip-26.2.1-py3-none-any.whl
OVERRIDES += packaging-25.0-py3-none-any.whl

OVERRIDES += setuptools_scm-8.1.0-py3-none-any.whl
OVERRIDES += setuptools_rust-1.10.2-py3-none-any.whl
OVERRIDES += cython-3.0.11.tar.gz
OVERRIDES += pyyaml-6.0.2.tar.gz
OVERRIDES += pymssql-2.3.1.tar.gz
OVERRIDES += paramiko-3.5.0-py3-none-any.whl

OVERRIDES += requests-2.33.0-py3-none-any.whl
OVERRIDES += urllib3-2.7.0-py3-none-any.whl
OVERRIDES += mysql_connector_python-9.5.0-py2.py3-none-any.whl
OVERRIDES += idna-3.18-py3-none-any.whl
OVERRIDES += pyasn1-0.6.4-py3-none-any.whl
OVERRIDES += pyparsing-3.3.2-py3-none-any.whl
OVERRIDES += flit_core-3.12.0-py3-none-any.whl
endif

export PIP_ROOT_USER_ACTION=ignore

# the proxy variables make any network access fail hard:
# the build is self-contained and must not reach the internet
build:
	mkdir -p $(WHEELSDIR)
	mkdir -p $(BUILDDEST)
	export PYTHONPATH=$(BUILDDEST):$$PYTHONPATH; \
	export http_proxy=http://external_dependencies_must_be_included_in_omd; \
	export https_proxy=http://external_dependencies_must_be_included_in_omd; \
	export ftp_proxy=http://external_dependencies_must_be_included_in_omd; \
	export CFLAGS="${CFLAGS} -std=c99"; \
	set -e ; \
	shopt -s nocaseglob; \
	for M in $(BASE) $(MODULES); do \
		MBASE=$$(echo $$M | sed -E -e 's/.tar.gz//g' -e 's/.zip//g' -e 's/-(py2\.)*py3-.*whl//g' -e 's/[-_]/\*/g') ; \
		echo "** $$M **"; \
		for O in $(OVERRIDES); do \
			if [[ $$O =~ $$(echo $${MBASE%\**} | tr A-Z a-z | sed -e 's/\*/.*/g')- ]]; then \
				echo "using $$O instead of $$M"; \
				M="$$O"; \
				MBASE=$$(echo $$M | sed -E -e 's/.tar.gz//g' -e 's/.zip//g' -e 's/-(py2\.)*py3-.*whl//g' -e 's/[-_]/\*/g') ; \
			fi; \
		done; \
		WHEEL=$$(ls $(WHEELSDIR)/$${MBASE}-* 2>/dev/null | head -1) ; \
		[[ -n "$$WHEEL" ]] && [[ -f "$$WHEEL" ]] && continue ; \
		if [[ $$M =~ .*mysql_connector_python.* ]]; then \
			if [[ "$$(printf '%s\n' "3.8" "$(PYTHON_V)" | sort -V | head -n 1)" != "3.8" ]]; then \
				echo "mysql_connector_python requires a python newer than 3.8, skipping"; \
				continue ; \
			fi; \
		fi; \
		if [[ $$M == *.whl ]]; then \
			cp src/$$M $(WHEELSDIR) ; \
		elif [[ $$M =~ .*pymssql.* ]]; then \
			if [ `uname -m` = 'armv7l' ]; then \
				export PYMSSQL_BUILD_WITH_BUNDLED_FREETDS=1 \
			else \
				export PYMSSQL_BUILD_WITH_BUNDLED_FREETDS=0 ; \
			fi; \
			LINK_KRB5=NO \
			CFLAGS="${CFLAGS} -I $(FREETDS)/include -L $(FREETDS)/lib" \
			$(PIP) wheel --no-cache-dir --no-index --no-deps --wheel-dir=$(WHEELSDIR) --find-links=$(WHEELSDIR) ./src/$$M ; \
		else \
			$(PIP) wheel --no-cache-dir --no-index --no-deps --wheel-dir=$(WHEELSDIR) --find-links=$(WHEELSDIR) ./src/$$M ; \
		fi ; \
		WHEEL=$$(ls $(WHEELSDIR)/$${MBASE}-* 2>/dev/null | head -1) ; \
		$(PIP) install --no-cache-dir --no-index --no-deps --find-links=$(WHEELSDIR) --target=$(BUILDDEST) --upgrade $$WHEEL ; \
	done

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

# dev-time helper: refresh the bundled files in src/ from upstream (PyPI).
# This is NOT part of the build - the build itself runs without internet.
upstream:
	set -e; cd src && \
	export WHEELSDIR=$$(realpath ../wheels); \
	for F in $(BASE) $(MODULES); do \
	    M=$$(echo $$F | sed -E -e 's/-(py2\.py3|py3)-none-any\.whl//' -e 's/\.tar\.gz//'); \
	    VERSION=$$(echo $$M | sed "s/^.*-\([0-9.]*\)$$/\1/"); \
	    MODULE=$$(echo $$M | sed "s/^\(.*\)-\([0-9.]*\)$$/\1/"); \
	    case $$MODULE in omd*) continue;; esac; \
	    $(PIP) download --find-links=$${WHEELSDIR} --progress-bar off --no-deps -d . $${MODULE}==$${VERSION}; \
	done
