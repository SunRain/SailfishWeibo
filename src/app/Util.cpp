
#include "Util.h"

#include <QSettings>
#include <QGuiApplication>
#include <QRegExp>
#include <QDir>
#include <QMutex>
#include <QScopedPointer>

#include <sailfishapp.h>

#include "MyNetworkAccessManagerFactory.h"
#include "Emoticons.h"
#include "Settings.h"

#include "TokenProvider.h"

Util *Util::getInstance()
{
    static QMutex mutex;
    static QScopedPointer<Util> scp;
    if (Q_UNLIKELY(scp.isNull())) {
        mutex.lock();
        scp.reset(new Util(0));
        mutex.unlock();
    }
    return scp.data();
}

Util::~Util()
{
    if (m_emoticons)
        m_emoticons->deleteLater ();
    m_emoticons = nullptr;
}

void Util::setEngine(QQmlEngine *engine)
{
    this->m_qmlEngine = engine;
}

/*
 * http://oauth.weico.cc/#access_token=
 * &remind_in=
 * &expires_in=
 * &refresh_token=
 */

bool Util::parseOauthTokenUrl(const QString &url)
{
    if (!url.contains ("access_token")
            || !url.contains ("expires_in")
            || !url.contains ("refresh_token")) {
        qDebug()<<Q_FUNC_INFO<<"url invalid";
        return false;
    }
    QStringList list = url.split ("#");
    if (list.empty () || list.size () < 2) {
        qDebug()<<Q_FUNC_INFO<<"url  size invalid";
        return false;
    }
    list = list.at (1).split ("&");
    foreach (QString s, list) {
        if (s.startsWith ("access_token")) {
            s = s.replace ("access_token=", "");
//            Settings::instance ()->setAccessToken (s);
            QWeiboSDK::TokenProvider::instance ()->setAccessToken (s);
        } else if (s.startsWith ("expires_in")) {
            s = s.replace ("expires_in=", "");
//            Settings::instance ()->setExpiresData (s);
            QWeiboSDK::TokenProvider::instance ()->setExpiresData (s);
        } else if (s.startsWith ("refresh_token")) {
            s = s.replace ("refresh_token=", "");
//            Settings::instance ()->setRefreshToken (s);
            QWeiboSDK::TokenProvider::instance ()->setRefreshToken (s);
        } else if (s.startsWith ("uid")) {
            s = s.replace ("uid=", "");
//            Settings::instance ()->setUid (s);
            QWeiboSDK::TokenProvider::instance ()->setUid (s);
        }
    }
    return true;
}

QString Util::getVerison()
{
#ifdef VERSION_STR
    return QString(VERSION_STR);
#else
    return QString("Unknown");
#endif
}

QUrl Util::pathTo(const QString &filename)
{
    return SailfishApp::pathTo (filename);
}

//void Util::setValue(const QString &key, const QVariant &value)
//{
//    if (m_Map.value(key) != value) {
//        m_Map.insert(key, value);
//        m_Settings->setValue(key, value);
//    }
//}

//QVariant Util::getValue(const QString &key, const QVariant defaultValue)
//{
//    if (m_Map.contains(key)){
//        return m_Map.value(key);
//    } else {
//        return m_Settings->value(key, defaultValue);
//    }
//}

bool Util::saveToCache(const QString &remoteUrl, const QString &dirName, const QString &fileName)
{
    if (m_qmlEngine.isNull()) {
        return false;
    }
    MyNetworkAccessManager *manage = (MyNetworkAccessManager*)m_qmlEngine.data ()->networkAccessManager();

    QAbstractNetworkCache *diskCache = manage->cache();

    if (diskCache == 0) {
        return false;
    }
    QIODevice *data = diskCache->data(QUrl(remoteUrl));
    if (data == 0) {
        return false;
    }
    //QString path = dir;
    QDir dir(dirName);
    if (!dir.exists()) dir.mkpath(dirName);
    QFile file(dirName + QDir::separator() + fileName);
    if (file.open(QIODevice::WriteOnly)){
        file.write(data->readAll());
        file.close();
        data->deleteLater();
        return true;
    }
	data->deleteLater();
    return false;
}

QString Util::parseWeiboContent(const QString &weiboContent, const QString &contentColor, const QString &userColor, const QString &linkColor)
{
    QString tmp = weiboContent;

    //注意这几行代码的顺序不能乱，否则会造成多次替换
    tmp.replace("&","&amp;");     
    tmp.replace(">","&gt;");
    tmp.replace("<","&lt;");
    tmp.replace("\"","&quot;");
    tmp.replace("\'","&#39;");
    tmp.replace(" ","&nbsp;");
    tmp.replace("\n","<br>");
    tmp.replace("\r","<br>");

    //'<font color="' +aa +'">aa + </font> <img src="' + '../emoticons/cool_org.png"' + '> <b>Hello</b> <i>World! ddddddddddddddddddddddddddd</i>'
    //设置主要字体
    QString content = QString("<font color=\"%1\">%2</font>").arg(contentColor).arg(tmp);

    //替换网页链接
    tmp = QString();
    int pos = -1;
    QString reText;

    QRegExp urlRE("http://[\\w+&@#/%?=~_\\\\-|!:,\\\\.;]*[\\w+&@#/%=~_|]");
                  //("http://[a-zA-Z0-9+&@#/%?=~_\\-|!:,\\.;]*[a-zA-Z0-9+&@#/%=~_|]");
                 //("http://([\\w-]+\\.)+[\\w-]+(/[A-Za-z0-9]*)");
    while((pos = urlRE.indexIn(content, pos+1)) != -1) {
        tmp = urlRE.cap(0);
        reText = QString("<a href=\"%1\"><font color=\"%2\">%3</font></a>").arg(tmp).arg(linkColor).arg(tmp);
                // "<a href=\"" +urlRE.cap(0) +"\">"+urlRE.cap(0)+"</a>";
        content.replace(pos, tmp.length(), reText);
        pos += reText.length();
    }

    //替换@用户
    pos = -1;
    reText = QString();
    tmp = QString();
    
    //"@[\\w\\p{InCJKUnifiedIdeographs}-]{1,26}"
    QRegExp atRE("@[\\w\\p{InCJKUnifiedIdeographs}-]{1,26}");

    while((pos = atRE.indexIn(content, pos+1)) != -1) {
        tmp = atRE.cap(0).replace("@", "@:");
        reText = QString("<a href=\"%1\"><font color=\"%2\">%3</font></a>").arg(tmp).arg(userColor).arg(atRE.cap(0));
                //"<a href=\"" +atRE.cap(0) +"\">"+atRE.cap(0)+"</a>";
        content.replace(pos, atRE.cap(0).length(), reText);
        pos += reText.length();
    }

    //替换表情符号
    content = parseEmoticons("\\[(\\S{1,2})\\]", content);
    content = parseEmoticons("\\[(\\S{3,4})\\]", content);
    return content;
}

QString Util::parseImageUrl(const QString &remoteUrl)
{
    QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    QByteArray byteArray = remoteUrl.toLocal8Bit().toBase64();
    QString fileName(byteArray);
    QString filePath = QString("%1%2%3").arg(cachePath).arg(QDir::separator()).arg(fileName);
    QFile file(filePath);
    if (file.exists()) {
        return filePath;
    }
    return remoteUrl;
    
}

void Util::saveRemoteImage(const QString &remoteUrl)
{
    QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    QByteArray byteArray = remoteUrl.toLocal8Bit().toBase64();
    QString fileName(byteArray);
    QString filePath = QString("%1%2%3").arg(cachePath).arg(QDir::separator()).arg(fileName);
    QFile file(filePath);
    if (file.exists()) {
        return;
    }
    saveToCache(remoteUrl, cachePath,fileName);
}

QString Util::getCachePath() const
{
    return QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
}

bool Util::deleteDir(const QString &dirName)
{
    if (dirName.isEmpty())  return false;
    
    QDir dir(dirName);
    if(!dir.exists()) return false;
    
    QFileInfoList files = dir.entryInfoList();
    if (files.isEmpty()) return false;
    
    QString tmpStr;
    foreach (QFileInfo info, files) {
        tmpStr = info.fileName();
        
        if (tmpStr == "." || tmpStr == "..") continue;
        
        if (info.isDir()) {
            QString d = QString("%1%2%3").arg(dirName).arg(QDir::separator()).arg(tmpStr);
            deleteDir(d);
        } else if (info.isFile()) {;
            dir.remove(QString("%1%2%3").arg(dirName).arg(QDir::separator()).arg(tmpStr));
        }
    }
    if (dir.exists(dirName)) {
        if(!dir.rmdir(dirName))
            return false;
    }
    
    return dir.entryInfoList().isEmpty();    
}

Util::Util(QObject *parent)
    :QObject(parent)
    ,m_settings(Settings::instance ())
    ,m_emoticons(nullptr)
{
}

QString Util::parseEmoticons(const QString &pattern, const QString &str)
{
    QString tmp = str;

    int  pos = 0;
    QString reText;
    QString emoticons;
    QRegExp emoticonRE(pattern);
    if (!m_emoticons)
        m_emoticons = new Emoticons(this);

    while((pos = emoticonRE.indexIn(tmp, pos)) != -1) {
        emoticons = emoticonRE.cap(0);
        emoticons = m_emoticons->getEmoticonName (emoticons);
        if (emoticons.isEmpty()) {
            pos += emoticonRE.cap(0).length();
            continue;
        }
        emoticons = SailfishApp::pathTo(QString("qml/emoticons/%1").arg(emoticons)).toString();
        ///FIXME 似乎以file:///path 形式的路径在qml里面显示有问题，所以去掉file：///，直接使用绝对路径
        emoticons = emoticons.replace("file:///", "/");   
        reText = QString("<img src=\"%1\">").arg(emoticons);
        tmp.replace(pos, emoticonRE.cap(0).length(), reText);
        pos += reText.length();
    }
     
    return tmp;
}
