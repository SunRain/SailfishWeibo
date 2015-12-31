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
TEMPLATE = subdirs
SUBDIRS += src

CONFIG += sailfishapp
CONFIG += c++11

OTHER_FILES += qml/SailfishWeibo.qml \
    qml/cover/*.qml \
    qml/pages/*.qml \
    qml/components/*.qml \
    qml/graphics/* \
    qml/js/*.js \
    qml/js/*.qml \
    qml/ui/*.qml \
    qml/graphics/* \
    qml/emoticons/* \
    rpm/harbour-sailfish_sinaweibo.changes.in \
    rpm/harbour-sailfish_sinaweibo.spec \
    rpm/harbour-sailfish_sinaweibo.yaml \
    harbour-sailfish_sinaweibo.desktop \
    translations/*



# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-sailfish_sinaweibo-de.ts \
                translations/harbour-sailfish_sinaweibo-zh_CN.ts


