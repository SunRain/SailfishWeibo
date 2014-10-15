TEMPLATE = subdirs
CONFIG += ordered
SUBDIRS = weiboAPI SailfishWeibo #tests

weiboAPI.file = QSinaWeiboApi/weiboAPI/SailfishWeiboAPI.pro
SailfishWeibo.depends += weiboAPI
