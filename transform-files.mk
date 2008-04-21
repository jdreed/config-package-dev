# -*- mode: makefile; coding: utf-8 -*-
# Copyright © 2008 Tim Abbott <tabbott@mit.edu> and
#                  Anders Kaseorg <andersk@mit.edu>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
# 02111-1307 USA.

ifndef _cdbs_rules_transform_files
_cdbs_rules_transform_files = 1

include /usr/share/cdbs/1/rules/check-files.mk

DEB_TRANSFORM_FILES = $(foreach package,$(DEB_ALL_PACKAGES),$(DEB_TRANSFORM_FILES_$(package)))

DEB_TRANSFORM_FILES_DIR=debian/transform_file_copies

debian_transform_files = $(patsubst %,$(DEB_TRANSFORM_FILES_DIR)%,$(1))
undebian_transform_files = $(patsubst $(DEB_TRANSFORM_FILES_DIR)%,%,$(1))

common-build-indep:: $(foreach file,$(DEB_TRANSFORM_FILES),$(call debian_transform_files,$(file)))

$(call debian_transform_files,%): $(call debian_check_files,%)
	mkdir -p $(@D)
	$(if $(DEB_TRANSFORM_SCRIPT_$(call undebian_transform_files,$@)), \
	    $(DEB_TRANSFORM_SCRIPT_$(call undebian_transform_files,$@)), \
	    debian/transform_$(notdir $(call undebian_transform_files,$@))) < $< > $@

$(patsubst %,binary-install/%,$(DEB_ALL_PACKAGES)) :: binary-install/%:
	$(foreach file,$(DEB_TRANSFORM_FILES_$(cdbs_curpkg)), \
		install -d $(DEB_DESTDIR)/$(dir $(file)); \
		cp -a $(DEB_TRANSFORM_FILES_DIR)$(file) \
		    $(DEB_DESTDIR)/$(dir $(file));)

clean::
	$(foreach file,$(DEB_TRANSFORM_FILES),rm -f debian/$(notdir $(file)))
	rm -rf $(DEB_TRANSFORM_FILES_DIR)

endif