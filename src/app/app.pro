TEMPLATE = app
# The name of your application
TARGET = harbour-sailfish_sinaweibo

CONFIG += sailfishapp

SOURCES += SailfishWeibo.cpp \
    networkhelper.cpp \
    mytype.cpp \
    MyNetworkAccessManagerFactory.cpp \
    Util.cpp \
    Emoticons.cpp

HEADERS += \
    networkhelper.h \
    mytype.h \
    app.h \
    MyNetworkAccessManagerFactory.h \
    Util.h \
    Emoticons.h


win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../QSinaWeiboApi/weiboAPI/ -lQSinaWeiboAPI
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../QSinaWeiboApi/weiboAPI/ -lQSinaWeiboAPId
else:unix: LIBS += -L$$OUT_PWD/../QSinaWeiboApi/weiboAPI/ -lQSinaWeiboAPI

INCLUDEPATH += $$PWD/../QSinaWeiboApi/weiboAPI
DEPENDPATH += $$PWD/../QSinaWeiboApi/weiboAPI

DEFINES += VERSION_STR=\\\"$$system($${PWD}/get_version_str.sh)\\\"

