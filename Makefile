PRODUCT := NoLockApp
DIST_DIR := dist
APP_NAME := NoLock
APP_BUNDLE := $(APP_NAME).app
BINARY_PATH := .build/release/$(PRODUCT)
DIST_BINARY := $(DIST_DIR)/$(APP_NAME)
APP_DIR := $(DIST_DIR)/$(APP_BUNDLE)
APP_EXECUTABLE := $(APP_NAME)
INFO_PLIST := App/Info.plist
APP_ICON_PNG ?= assets/icon.png
ICONSET_DIR := .build/$(APP_NAME).iconset
ICON_ICNS := .build/$(APP_NAME).icns
MODULE_CACHE_DIR := .build/ModuleCache
BUILD_ENV := CLANG_MODULE_CACHE_PATH=$(PWD)/$(MODULE_CACHE_DIR) SWIFTPM_MODULECACHE_OVERRIDE=$(PWD)/$(MODULE_CACHE_DIR)

.PHONY: all build-release clean-dist binary app icon

all: binary app

build-release:
	mkdir -p $(MODULE_CACHE_DIR)
	$(BUILD_ENV) swift build -c release --product $(PRODUCT)

clean-dist:
	rm -rf $(DIST_DIR)

binary: build-release
	mkdir -p $(DIST_DIR)
	cp $(BINARY_PATH) $(DIST_BINARY)
	chmod +x $(DIST_BINARY)
	@echo "Built binary: $(DIST_BINARY)"

app: build-release
	mkdir -p $(DIST_DIR)
	rm -rf $(APP_DIR)
	mkdir -p $(APP_DIR)/Contents/MacOS $(APP_DIR)/Contents/Resources
	cp $(BINARY_PATH) $(APP_DIR)/Contents/MacOS/$(APP_EXECUTABLE)
	chmod +x $(APP_DIR)/Contents/MacOS/$(APP_EXECUTABLE)
	cp $(INFO_PLIST) $(APP_DIR)/Contents/Info.plist
	@if [ -f "$(APP_ICON_PNG)" ]; then \
		$(MAKE) icon APP_ICON_PNG="$(APP_ICON_PNG)"; \
		cp $(ICON_ICNS) $(APP_DIR)/Contents/Resources/$(APP_NAME).icns; \
		echo "Using app icon from $(APP_ICON_PNG)"; \
	else \
		echo "No $(APP_ICON_PNG) found; building app with default icon."; \
	fi
	@echo "Built app bundle: $(APP_DIR)"

icon:
	rm -rf $(ICONSET_DIR)
	mkdir -p $(ICONSET_DIR)
	sips -z 16 16 $(APP_ICON_PNG) --out $(ICONSET_DIR)/icon_16x16.png >/dev/null
	sips -z 32 32 $(APP_ICON_PNG) --out $(ICONSET_DIR)/icon_16x16@2x.png >/dev/null
	sips -z 32 32 $(APP_ICON_PNG) --out $(ICONSET_DIR)/icon_32x32.png >/dev/null
	sips -z 64 64 $(APP_ICON_PNG) --out $(ICONSET_DIR)/icon_32x32@2x.png >/dev/null
	sips -z 128 128 $(APP_ICON_PNG) --out $(ICONSET_DIR)/icon_128x128.png >/dev/null
	sips -z 256 256 $(APP_ICON_PNG) --out $(ICONSET_DIR)/icon_128x128@2x.png >/dev/null
	sips -z 256 256 $(APP_ICON_PNG) --out $(ICONSET_DIR)/icon_256x256.png >/dev/null
	sips -z 512 512 $(APP_ICON_PNG) --out $(ICONSET_DIR)/icon_256x256@2x.png >/dev/null
	sips -z 512 512 $(APP_ICON_PNG) --out $(ICONSET_DIR)/icon_512x512.png >/dev/null
	sips -z 1024 1024 $(APP_ICON_PNG) --out $(ICONSET_DIR)/icon_512x512@2x.png >/dev/null
	iconutil -c icns $(ICONSET_DIR) -o $(ICON_ICNS)
