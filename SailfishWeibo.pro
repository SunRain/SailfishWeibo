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

OTHER_FILES += qml/SailfishWeibo.qml \
    qml/cover/*.qml \
    qml/pages/*.qml \
    qml/components/*.qml \
    qml/graphics/*.png \
    qml/js/*.js \
    qml/js/*.qml \
    qml/ui/*.qml \
    qml/emoticons/* \
    rpm/SailfishWeibo.changes.in \
    rpm/SailfishWeibo.spec \
    rpm/SailfishWeibo.yaml \
    translations/*.ts \
    SailfishWeibo.desktop
    
# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/SailfishWeibo-de.ts \
                translations/SailfishWeibo-zh_CN.ts


