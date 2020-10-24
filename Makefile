top_srcdir ?= .
srcdir     ?= $(top_srcdir)
builddir   ?= $(top_srcdir)/docs
shaderdir  ?= $(top_srcdir)/shaders
vendordir  ?= $(top_srcdir)/glsl-sandbox

buildjsdir = $(builddir)/js
vendorjsdir = $(vendordir)/static/js
buildcssdir = $(builddir)/css
vendorcssdir = $(vendordir)/static/css

VENDOR_CSS_FILES = \
	codemirror.css \
	default.css \
	resizer.png

VENDOR_JS_FILES = \
	jquery.js \
	codemirror.js \
	glsl.js

TARGET_CSS = $(addprefix $(buildcssdir)/,$(VENDOR_CSS_FILES))
VENDOR_CSS = $(addprefix $(vendorcssdir)/,$(VENDOR_CSS_FILES))
TARGET_JS = $(addprefix $(buildjsdir)/,$(VENDOR_JS_FILES))
VENDOR_JS = $(addprefix $(vendorjsdir)/,$(VENDOR_JS_FILES))

SHADER_SRC = $(wildcard $(shaderdir)/*.frag.glsl)
TARGET_VIEWERS = $(patsubst $(shaderdir)/%.frag.glsl,$(builddir)/%.html,$(SHADER_SRC))

VIEWER_TEMPLATE = $(srcdir)/viewer_template.html
BUILD_INDEX = $(srcdir)/build_index.sh
TARGET_INDEX = $(builddir)/index.html

TARGETS = \
	$(TARGET_CSS) \
	$(TARGET_JS) \
	$(TARGET_VIEWERS) \
	$(TARGET_INDEX)


######################################################################

CP    ?= cp
RM    ?= rm -f
RMDIR ?= rmdir --ignore-fail-on-non-empty


######################################################################

all: build
build: $(TARGETS)

$(TARGET_CSS): | $(buildcssdir)
$(TARGET_JS): | $(buildjsdir)

$(builddir):
	mkdir -p $(builddir)
$(buildcssdir): | $(builddir)
	mkdir -p $(buildcssdir)
$(buildjsdir): | $(builddir)
	mkdir -p $(buildjsdir)

$(buildcssdir)/%: $(vendorcssdir)/%
	$(CP) $< $@
$(buildjsdir)/%: $(vendorjsdir)/%
	$(CP) $< $@

$(builddir)/%.html: $(shaderdir)/%.frag.glsl $(VIEWER_TEMPLATE)
	sed -e '/script id="customShader"/r$<' $(VIEWER_TEMPLATE) > $@

$(TARGET_INDEX): $(SHADER_SRC)
	$(BUILD_INDEX) $(shaderdir) > $(TARGET_INDEX)

clean-vendor:
	@for file in $(TARGET_CSS) $(TARGET_JS) ; do \
	    if test -f $$file ; then \
	        echo "$(RM) $$file" ; \
	        $(RM) $$file ; \
	    fi ; \
	done
	@for dir in $(buildcssdir) $(buildjsdir) ; do \
	    if test -d $$dir && test -z `ls -A $$dir` ; then \
	        echo "$(RMDIR) $$dir/" ; \
	        $(RMDIR) $$dir/ ; \
	    fi \
	done

clean-viewers:
	@for file in $(TARGET_VIEWERS) ; do \
	    if test -f $$file ; then \
	        echo "$(RM) $$file" ; \
	        $(RM) $$file ; \
	    fi ; \
	done

clean-index:
	@for file in $(TARGET_INDEX) ; do \
	    if test -f $$file ; then \
	        echo "$(RM) $$file" ; \
	        $(RM) $$file ; \
	    fi ; \
	done

clean: clean-vendor clean-viewers clean-index

.PHONY: all build clean clean-vendor clean-viewers clean-index
