LOTTIE_FRAMEWORK_PATH = .build/artifacts/lottie-spm/Lottie/Lottie.xcframework/macos-arm64_x86_64/Lottie.framework
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
	@mkdir -p $(BUNDLE_DIR)/Contents/Frameworks
	cp -R $(LOTTIE_FRAMEWORK_PATH) $(BUNDLE_DIR)/Contents/Frameworks/Lottie.framework
	cp $(EXECUTABLE) $(BUNDLE_DIR)/Contents/MacOS/TimeTracker
	install_name_tool -add_rpath @executable_path/../Frameworks $(BUNDLE_DIR)/Contents/MacOS/TimeTracker
	codesign --force --sign - $(BUNDLE_DIR)

release:
	$(MAKE) BUILD_CONFIG=release bundle

run: bundle
	open $(BUNDLE_DIR)

run-debug: bundle
	$(BUNDLE_DIR)/Contents/MacOS/TimeTracker

clean:
	swift package clean
	rm -rf build
