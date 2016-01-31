TEMPLATE = subdirs
CONFIG += ordered

pymodule.file = WeiboPyModule/sailfishweibopy.pro
pymodule.depends = mainapp

mainapp.file = harbour-sailfish_sinaweibo.pro

SUBDIRS += mainapp pymodule
