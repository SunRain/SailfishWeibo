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
TARGET = SailfishWeibo

CONFIG += sailfishapp

SOURCES += src/SailfishWeibo.cpp \
    src/networkhelper.cpp \
    src/mytype.cpp

OTHER_FILES += qml/SailfishWeibo.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SecondPage.qml \
    rpm/SailfishWeibo.changes.in \
    rpm/SailfishWeibo.spec \
    rpm/SailfishWeibo.yaml \
    translations/*.ts \
    SailfishWeibo.desktop \
    qml/aesyweibo.qml \
    qml/components/Notification.qml \
    qml/components/FooterLoadMore.qml \
    qml/components/DelegateWeibo.qml \
    qml/components/DelegateRepostedWeibo.qml \
    qml/graphics/up.png \
    qml/graphics/toolbarIcon@8.png \
    qml/graphics/Thumbs.db \
    qml/graphics/reload.svg \
    qml/graphics/folder.png \
    qml/graphics/edit.svg \
    qml/js/weiboapi.js \
    qml/js/getURL.js \
    qml/js/dateutils.js \
    qml/js/addImages.js \
    qml/js/WeiboApiHandler.qml \
    qml/ui/WeiboTab.qml \
    qml/ui/WeiboPage.qml \
    qml/ui/WeiboMentioned.qml \
    qml/ui/UserWeibo.qml \
    qml/ui/UserTab.qml \
    qml/ui/UserPhoto.qml \
    qml/ui/UserPage.qml \
    qml/ui/SettingTab.qml \
    qml/ui/SendPage.qml \
    qml/ui/MessageTab.qml \
    qml/ui/LocalPhotoPicker.qml \
    qml/ui/HelloTab.qml \
    qml/ui/Gallery.qml \
    qml/ui/FriendsPage.qml \
    qml/ui/CommentMentioned.qml \
    qml/ui/CommentAllPage.qml \
    qml/ui/AboutPage.qml \
    qml/js/LocalStore.js \
    qml/js/Settings.js \
    qml/components/MainComponent.qml \
    qml/ui/BusyIndicator.qml \
    qml/components/LoginSheet.qml
    
# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/SailfishWeibo-de.ts

HEADERS += \
    src/networkhelper.h \
    src/mytype.h \
    src/app.h

