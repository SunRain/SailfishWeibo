TEMPLATE = app
# The name of your application
TARGET = SailfishWeibo

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


win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../QSinaWeiboApi/weiboAPI/ -lSailfishWeibo
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../QSinaWeiboApi/weiboAPI/ -lSailfishWeibod
else:unix: LIBS += -L$$OUT_PWD/../QSinaWeiboApi/weiboAPI/ -lSailfishWeibo

INCLUDEPATH += $$PWD/../QSinaWeiboApi/weiboAPI
DEPENDPATH += $$PWD/../QSinaWeiboApi/weiboAPI
