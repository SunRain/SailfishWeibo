TEMPLATE = app
# The name of your application
TARGET = harbour-sailfish_sinaweibo

QT += qml quick network

CONFIG += sailfishapp sailfishapp_no_deploy_qml
CONFIG += c++11
CONFIG += WITH_HACKLOGIN WITH_SDK_WRAPPER

QMAKE_CFLAGS_DEBUG += -fPIC
QMAKE_CFLAGS_RELEASE += -fPIC
QMAKE_CXXFLAGS += -fPIC

DEFINES += \
    SAILFISH_OS

win32 {
    DEFINES += \
        VERSION_STR="win32_dummy"
}
unix {
    DEFINES += \
        VERSION_STR=\\\"$$system($${PWD}/get_version_str.sh)\\\"
}

include (src/QSinaWeiboApi/QWeiboSDK/QWeiboSDK.pri)

OTHER_FILES += \
    rpm/harbour-sailfish_sinaweibo.changes.in \
    rpm/harbour-sailfish_sinaweibo.spec \
    rpm/harbour-sailfish_sinaweibo.yaml \
    harbour-sailfish_sinaweibo.desktop \
    translations/* \
    qml/pages/*.qml \
    qml/components/*.qml \
    qml/cover/*.qml \
    qml/ui/*.qml \
    qml/requests/*.qml \
    qml/SailfishWeibo.qml \
    qml/js/*.js \
    qml/WeiboFunctions.qml

graphics.path = /usr/share/$${TARGET}/qml/graphics
graphics.files += qml/graphics/*
INSTALLS += graphics

emoticons.path = /usr/share/$${TARGET}/qml/emoticons
emoticons.files += qml/emoticons/*
INSTALLS += emoticons

warning.path = /usr/share/$${TARGET}/qml
warning.files += qml/warning.html
INSTALLS += warning

###############################################
# ugly hack for i486 and arm platform
# Currently, I can only distinguish between i486 and arm from this g++ flag
####################
#arm
linux-g++ {
    lib_armv7hl.path = /usr/share/$${TARGET}/lib/armv7hl
    lib_armv7hl.files += \
        prelibrary/htmlcxx/armv7hl/libcss_parser_pp.so \
        prelibrary/htmlcxx/armv7hl/libcss_parser_pp.so.0 \
        prelibrary/htmlcxx/armv7hl/libcss_parser.so \
        prelibrary/htmlcxx/armv7hl/libcss_parser.so.0 \
        prelibrary/htmlcxx/armv7hl/libhtmlcxx.so \
        prelibrary/htmlcxx/armv7hl/libhtmlcxx.so.3
    INSTALLS += lib_armv7hl
}

#i486
linux-g++-32 {
    lib_i486.path = /usr/share/$${TARGET}/lib/i486
    lib_i486.files += \
        prelibrary/htmlcxx/i486/libcss_parser_pp.so \
        prelibrary/htmlcxx/i486/libcss_parser_pp.so.0 \
        prelibrary/htmlcxx/i486/libcss_parser.so \
        prelibrary/htmlcxx/i486/libcss_parser.so.0 \
        prelibrary/htmlcxx/i486/libhtmlcxx.so \
        prelibrary/htmlcxx/i486/libhtmlcxx.so.3
    INSTALLS += lib_i486
}

INCLUDEPATH += $$PWD/prelibrary/htmlcxx/include
LIBS += \
    -lhtmlcxx \
    -lcss_parser_pp \
    -lcss_parser

#QMAKE_LFLAGS_RPATH += \
#    /usr/share/$${TARGET}/lib \
#    /usr/share/$${TARGET}/lib/i486 \
#    /usr/share/$${TARGET}/lib/armv7hl \
#    $$PWD/prelibrary/htmlcxx/armv7hl \
#    $$PWD/prelibrary/htmlcxx/i486

QMAKE_RPATHDIR += \
    /usr/share/$${TARGET}/lib \
    /usr/share/$${TARGET}/lib/i486 \
    /usr/share/$${TARGET}/lib/armv7hl \
    $$PWD/prelibrary/htmlcxx/armv7hl \
    $$PWD/prelibrary/htmlcxx/i486

QMAKE_LIBDIR += \
    /usr/share/$${TARGET}/lib \
    /usr/share/$${TARGET}/lib/i486 \
    /usr/share/$${TARGET}/lib/armv7hl \
    $$PWD/prelibrary/htmlcxx/armv7hl \
    $$PWD/prelibrary/htmlcxx/i486

HEADERS += \
    src/app/Emoticons.h \
    src/app/Settings.h \
    src/app/WBNetworkAccessManagerFactory.h \
    src/app/WBNetworkAccessManager.h \
    src/app/Utility.h \
    src/app/WBContentParser.h

SOURCES += \
    src/app/Emoticons.cpp \
    src/app/SailfishWeibo.cpp \
    src/app/Settings.cpp \
    src/app/WBNetworkAccessManagerFactory.cpp \
    src/app/WBNetworkAccessManager.cpp \
    src/app/Utility.cpp \
    src/app/WBContentParser.cpp

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-sailfish_sinaweibo-de.ts \
                translations/harbour-sailfish_sinaweibo-zh_CN.ts

RESOURCES += \
    qml/resource.qrc

win32 {
    COPY = copy /y
    MKDIR = mkdir
} else {
    COPY = cp
    MKDIR = mkdir -p
}

#url=http://htmlcxx.sourceforge.net/
#prefix=/usr
#exec_prefix=${prefix}
#libdir=${prefix}/lib/x86_64-linux-gnu
#includedir=${prefix}/include

#Name: htmlcxx
#Description: html and css apis for c++
#Version: 0.85
#Libs: -L${libdir} -lhtmlcxx -lcss_parser_pp -lcss_parser
#Cflags: -I${includedir}
#URL: ${url}


#!equals($${_PRO_FILE_PWD_}, $${OUT_PWD}) {
#    for(f, OTHER_FILES){
#        #TODO need windows basename cmd
#        unix:base_name = $$basename(f)
#        dist = $${OUT_PWD}/$${PLUGINS_PREFIX}
#        dist_file = $${OUT_PWD}/$${PLUGINS_PREFIX}/$${base_name}
#        !exists($$dist):system($$MKDIR $$dist)
#        !exists($$dist_file):system($$COPY $$f $$dist_file)
#    }
#}

LIB_BUILD_DIR = $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build
BUILD_LIB = cd $$LIB_BUILD_DIR \
    && ../htmlcxx/configure --enable-shared --enable-static \
    && make
#system ($$MKDIR $$LIB_BUILD_DIR)
#system ($$BUILD_LIB)

#TAGLIB_FILE = \
#    $$PWD/../../../ThirdParty/Taglib/target/lib/*.so \
#    $$PWD/../../../ThirdParty/Taglib/target/lib/*.so.*

#taglib.files = $${TAGLIB_FILE}
#!isEmpty(UBUNTU_MANIFEST_FILE){
#    taglib.path = $${UBUNTU_CLICK_PLUGIN_PATH}/lib
#} else {
#    taglib.path = $${LIB_DIR}/lib
#}
#INSTALLS += taglib

#COPY_LIB = cd $${TAGLIB_TARGET_DIR}/lib \
#    && for i in `ls`;do if [ -f $i ];then $$COPY $i $${OUT_PWD}/../../../target/lib;fi;done

#system ($$COPY_LIB)


#INCLUDEPATH += \
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/css \
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/html

#DEPENDPATH += \
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/css \
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/html

#win32-g++:CONFIG(release, debug|release): LIBS += \
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/release/libcss_parser.a \
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/release/libcss_parser_pp.a \
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/html/.libs/release/libhtmlcxx.a
#else:win32-g++:CONFIG(debug, debug|release): LIBS += \
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/debug/libcss_parser.a\
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/debug/libcss_parser_pp.a \
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/html/.libs/debug/libhtmlcxx.a
#else:win32:!win32-g++:CONFIG(release, debug|release): LIBS += \
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/release/css_parser.lib \
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/release/css_parser_pp.lib \
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/html/.libs/release/htmlcxx.lib
#else:win32:!win32-g++:CONFIG(debug, debug|release): LIBS += \
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/debug/css_parser.lib \
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/debug/css_parser_pp.lib \
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/html/.libs/debug/htmlcxx.lib
#else:unix: LIBS += \
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/libcss_parser.a \
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/css/.libs/libcss_parser_pp.a \
#        $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx-build/html/.libs/libhtmlcxx.a
