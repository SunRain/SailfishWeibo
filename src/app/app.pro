TEMPLATE = app
# The name of your application
TARGET = SailfishWeibo

CONFIG += sailfishapp

SOURCES += SailfishWeibo.cpp \
    networkhelper.cpp \
    mytype.cpp \
    MyNetworkAccessManagerFactory.cpp \
    Util.cpp \
    Emoticons.cpp \
    ../QSinaWeiboApi/weiboAPI/QSinaWeibo.cpp \
    ../QSinaWeiboApi/weiboAPI/qweiboapi_global.cpp \
    ../QSinaWeiboApi/weiboAPI/QWeiboMethod.cpp \
    ../QSinaWeiboApi/weiboAPI/QWeiboPut.cpp \
    ../QSinaWeiboApi/weiboAPI/QWeiboRequest.cpp \
    ../QSinaWeiboApi/weiboAPI/QWeiboObject.cpp

HEADERS += \
    networkhelper.h \
    mytype.h \
    app.h \
    MyNetworkAccessManagerFactory.h \
    Util.h \
    Emoticons.h \
    ../QSinaWeiboApi/weiboAPI/include/dptr.h \
    ../QSinaWeiboApi/weiboAPI/include/QSinaWeibo.h \
    ../QSinaWeiboApi/weiboAPI/include/qweiboapi_global.h \
    ../QSinaWeiboApi/weiboAPI/include/QWeiboMethod.h \
    ../QSinaWeiboApi/weiboAPI/include/QWeiboPut.h \
    ../QSinaWeiboApi/weiboAPI/include/QWeiboRequest.h \
    ../QSinaWeiboApi/weiboAPI/include/QWeiboRequestApiList.h \
    ../QSinaWeiboApi/weiboAPI/include/version.h \
    ../QSinaWeiboApi/weiboAPI/include/QWeiboObject.h


#win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../QSinaWeiboApi/weiboAPI/ -lQSinaWeiboAPI
#else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../QSinaWeiboApi/weiboAPI/ -lQSinaWeiboAPId
#else:unix: LIBS += -L$$OUT_PWD/../QSinaWeiboApi/weiboAPI/ -lQSinaWeiboAPI

INCLUDEPATH += $$PWD/../QSinaWeiboApi/weiboAPI
DEPENDPATH += $$PWD/../QSinaWeiboApi/weiboAPI

#OTHER_FILES += \
#    ../QSinaWeiboApi/weiboAPI/SailfishWeiboAPI.pro \
#    ../QSinaWeiboApi/weiboAPI/weiboAPI.pro
