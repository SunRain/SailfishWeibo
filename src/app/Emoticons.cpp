
#include "Emoticons.h"

#include <sailfishapp.h>

#include <QScopedPointer>
#include <QMutex>
#include <QFile>
#include <QStringList>
#include <QDebug>

Emoticons::Emoticons(QObject *parent)
    :QObject(parent)
{
    initData();
}


Emoticons::~Emoticons()
{
    if (!m_emoticonsList.isEmpty()) {
        m_emoticonsList.clear();
    }
}

QString Emoticons::getEmoticonName(const QString &name)
{
    QString key = name;
    if (key.contains("[")) key.replace("[", "");
    if (key.contains("]")) key.replace("]", "");
    return m_emoticonsList.value(key, QString());
}

void Emoticons::initData()
{
    if (!m_emoticonsList.isEmpty()) {
        m_emoticonsList.clear();
    }
    QString path = SailfishApp::pathTo(QString("qml/emoticons/emoticons.dat")).toString().replace("file:///", "/");
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning()<<Q_FUNC_INFO<<"Can't find emoticons data file!!";
        return;
    }
    QString line;
    QStringList list;
    while(!file.atEnd()) {
        line = file.readLine().trimmed();
        if (line.length() > 0 && line.contains("||")) {
            list = line.split("||");
            m_emoticonsList.insert(list.at(0), list.at(1));
        }
    }
}

