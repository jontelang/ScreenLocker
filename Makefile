TARGET=:clang 
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = ScreenLocker
ScreenLocker_FILES = Tweak.xm
ScreenLocker_FRAMEWORKS = UIKit
ScreenLocker_LIBRARIES = activator

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"