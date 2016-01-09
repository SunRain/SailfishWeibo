TEMPLATE = app
# The name of your application
TARGET = harbour-sailfish_sinaweibo

QT += qml quick network

CONFIG += sailfishapp sailfishapp_no_deploy_qml
CONFIG += c++11

DEFINES += \
    VERSION_STR=\\\"$$system($${PWD}/get_version_str.sh)\\\" \
    SAILFISH_OS

include (src/QSinaWeiboApi/QWeiboSDK/QWeiboSDK.pri)

OTHER_FILES += \
    rpm/harbour-sailfish_sinaweibo.changes.in \
    rpm/harbour-sailfish_sinaweibo.spec \
    rpm/harbour-sailfish_sinaweibo.yaml \
    harbour-sailfish_sinaweibo.desktop \
    translations/*

graphics.path = /usr/share/$${TARGET}/qml/graphics
graphics.files += qml/graphics/*
INSTALLS += graphics

emoticons.path = /usr/share/$${TARGET}/qml/emoticons
emoticons.files += qml/emoticons/*
INSTALLS += emoticons


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

