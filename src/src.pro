TEMPLATE = subdirs
QSinaWeiboApi.file = QSinaWeiboApi/weiboAPI/SailfishWeiboAPI.pro
qml.file = qml/qml.pro
app.depends = QSinaWeiboApi qml
SUBDIRS += QSinaWeiboApi app qml
