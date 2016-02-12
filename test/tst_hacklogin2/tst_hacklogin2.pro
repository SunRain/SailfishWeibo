# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = tst_hacklogin2
QT += qml quick network

CONFIG += sailfishapp
CONFIG += c++11
CONFIG += WITH_HACKLOGIN WITH_SDK_WRAPPER

QMAKE_CFLAGS_DEBUG += -fPIC
QMAKE_CFLAGS_RELEASE += -fPIC
QMAKE_CXXFLAGS += -fPIC

include (../../src/QSinaWeiboApi/QWeiboSDK/QWeiboSDK.pri)

SOURCES += src/tst_hacklogin.cpp

OTHER_FILES += qml/tst_hacklogin.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SecondPage.qml \
    rpm/tst_hacklogin.changes.in \
    rpm/tst_hacklogin.spec \
    rpm/tst_hacklogin.yaml \
    translations/*.ts \
    tst_hacklogin.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/tst_hacklogin-de.ts

INCLUDEPATH += \
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/css \
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/html

DEPENDPATH += \
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/css \
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/html

win32-g++:CONFIG(release, debug|release): LIBS += \
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/release/libcss_parser.a \
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/release/libcss_parser_pp.a \
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/html/.libs/release/libhtmlcxx.a
else:win32-g++:CONFIG(debug, debug|release): LIBS += \
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/debug/libcss_parser.a\
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/debug/libcss_parser_pp.a \
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/html/.libs/debug/libhtmlcxx.a
else:win32:!win32-g++:CONFIG(release, debug|release): LIBS += \
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/release/css_parser.lib \
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/release/css_parser_pp.lib \
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/html/.libs/release/htmlcxx.lib
else:win32:!win32-g++:CONFIG(debug, debug|release): LIBS += \
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/debug/css_parser.lib \
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/debug/css_parser_pp.lib \
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/html/.libs/debug/htmlcxx.lib
else:unix: LIBS += \
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/libcss_parser.a \
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/libcss_parser_pp.a \
        $$PWD/../../src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/html/.libs/libhtmlcxx.a
