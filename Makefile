BUNDLE_NAME = TimeTracker
BUNDLE_DIR = build/$(BUNDLE_NAME).app
BUILD_CONFIG ?= debug
EXECUTABLE = .build/$(BUILD_CONFIG)/TimeTracker

.PHONY: build bundle run run-debug clean release

build:
	swift build -c $(BUILD_CONFIG)

bundle: build
	@mkdir -p $(BUNDLE_DIR)/Contents/MacOS
	@mkdir -p $(BUNDLE_DIR)/Contents/Resources
	cp $(EXECUTABLE) $(BUNDLE_DIR)/Contents/MacOS/TimeTracker
	cp Support/Info.plist $(BUNDLE_DIR)/Contents/Info.plist

release:
	$(MAKE) BUILD_CONFIG=release bundle

run: bundle
	open $(BUNDLE_DIR)

run-debug: bundle
	$(BUNDLE_DIR)/Contents/MacOS/TimeTracker

clean:
	swift package clean
	rm -rf build
