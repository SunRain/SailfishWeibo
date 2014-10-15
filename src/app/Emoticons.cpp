#include <sailfishapp.h>
#include "Emoticons.h"

Emoticons *Emoticons::getInstance()
{
    static Emoticons e;
    return &e;
}

Emoticons::~Emoticons()
{
    if (!m_emoticonsHash.isEmpty()) {
        m_emoticonsHash.clear();
    }
}

QString Emoticons::getEmoticonName(const QString &name)
{
    QString key = name;
    if (key.contains("[")) key.replace("[", "");
    if (key.contains("]")) key.replace("]", "");
    return m_emoticonsHash.value(key, "");
}

Emoticons::Emoticons(QObject *parent)
    :QObject(parent)
{
    initData();
}

void Emoticons::initData()
{
    if (!m_emoticonsHash.isEmpty()) {
        m_emoticonsHash.clear();
    }
    QString path = SailfishApp::pathTo(QString("qml/emoticons/emoticons.dat")).toString().replace("file:///", "/");
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return;
    }
    QString line;
    QStringList list;
    while(!file.atEnd()) {
        line = file.readLine().trimmed();
        if (line.length() > 0 && line.contains("||")) {
            list = line.split("||");
            m_emoticonsHash.insert(list.at(0), list.at(1));
        }
    }
}

