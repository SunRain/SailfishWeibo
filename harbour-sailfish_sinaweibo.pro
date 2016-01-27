TEMPLATE = app
# The name of your application
TARGET = harbour-sailfish_sinaweibo

QT += qml quick network

CONFIG += sailfishapp sailfishapp_no_deploy_qml
CONFIG += c++11
CONFIG += WITH_HACKLOGIN

DEFINES += \
    VERSION_STR=\\\"$$system($${PWD}/get_version_str.sh)\\\" \
    SAILFISH_OS

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
    qml/SailfishWeibo.qml \
    qml/js/*.js

graphics.path = /usr/share/$${TARGET}/qml/graphics
graphics.files += qml/graphics/*
INSTALLS += graphics

emoticons.path = /usr/share/$${TARGET}/qml/emoticons
emoticons.files += qml/emoticons/*
INSTALLS += emoticons

warning.path = /usr/share/$${TARGET}/qml
warning.files += qml/warning.html
INSTALLS += warning

HEADERS += \
    src/app/app.h \
    src/app/Emoticons.h \
    src/app/mytype.h \
    src/app/networkhelper.h \
    src/app/Settings.h \
    src/app/Util.h \
    src/app/WBNetworkAccessManagerFactory.h \
    src/app/WBNetworkAccessManager.h \

SOURCES += \
    src/app/Emoticons.cpp \
    src/app/mytype.cpp \
    src/app/networkhelper.cpp \
    src/app/SailfishWeibo.cpp \
    src/app/Settings.cpp \
    src/app/Util.cpp \
    src/app/WBNetworkAccessManagerFactory.cpp \
    src/app/WBNetworkAccessManager.cpp

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

TAGLIB_BUILD_DIR = $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/build
TAGLIB_TARGET_DIR = $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/target
BUILD_TAGLIB = cd $$TAGLIB_BUILD_DIR \
    && ../configure --enable-shared --enable-static \
    && make
#    && make install
system ($$MKDIR $$TAGLIB_BUILD_DIR)
system ($$MKDIR $$TAGLIB_TARGET_DIR)
system ($$BUILD_TAGLIB)

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



unix:!macx: LIBS += -L$$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/build/ -lcss_parser_pp

INCLUDEPATH += $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/build/css
DEPENDPATH += $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/build/css

unix:!macx: PRE_TARGETDEPS += $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/build/libcss_parser_pp.a

unix:!macx: LIBS += -L$$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/build/ -lcss_parser

INCLUDEPATH += $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/build/css
DEPENDPATH += $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/build/css

unix:!macx: PRE_TARGETDEPS += $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/build/libcss_parser.a

unix:!macx: LIBS += -L$$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/build/ -lhtmlcxx

INCLUDEPATH += $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/build/html
DEPENDPATH += $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/build/html

unix:!macx: PRE_TARGETDEPS += $$PWD/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx/build/libhtmlcxx.a
