BUNDLE_NAME = TimeTracker
BUNDLE_DIR = build/$(BUNDLE_NAME).app
EXECUTABLE = .build/debug/TimeTracker

.PHONY: build bundle run run-debug clean

build:
	swift build

bundle: build
	@mkdir -p $(BUNDLE_DIR)/Contents/MacOS
	@mkdir -p $(BUNDLE_DIR)/Contents/Resources
	cp $(EXECUTABLE) $(BUNDLE_DIR)/Contents/MacOS/TimeTracker
	cp Support/Info.plist $(BUNDLE_DIR)/Contents/Info.plist

run: bundle
	open $(BUNDLE_DIR)

run-debug: bundle
	$(BUNDLE_DIR)/Contents/MacOS/TimeTracker

clean:
	swift package clean
	rm -rf build
