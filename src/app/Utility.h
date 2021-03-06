﻿#ifndef UTILITY_H
#define UTILITY_H

#include <QObject>
#include <QSettings>
#include <QQmlEngine>
#include <QPointer>

#include "SingletonPointer.h"

class Settings;
class Emoticons;
class Utility : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString getCachePath READ getCachePath CONSTANT)
    Q_PROPERTY(QString getVerison READ getVerison CONSTANT)

    DECLARE_SINGLETON_POINTER(Utility)
public:
//    static Util *getInstance();
    virtual ~Utility();
    
//    void setEngine(QQmlEngine* engine);
    
public:
//    Q_INVOKABLE void setValue(const QString &key, const QVariant &value);
//    Q_INVOKABLE QVariant getValue(const QString &key, const QVariant defaultValue = QVariant());
    Q_INVOKABLE bool saveToCache(const QString &remoteUrl, const QString &dirName, const QString &fileName);
    
//    //解析微博内容，替换表情/链接等
//    Q_INVOKABLE QString parseWeiboContent(const QString &weiboContent,
//                                          const QString &contentColor,
//                                          const QString &userColor,
//                                          const QString &linkColor);
    ///解析图片链接，返回本地缓存/远程链接
    Q_INVOKABLE QUrl parseImageUrl(const QString &remoteUrl);
    Q_INVOKABLE void saveRemoteImage(const QString &remoteUrl);
    
    ///
    /// \brief getCachePath
    /// \return QStandardPaths::writableLocation(QStandardPaths::CacheLocatio
    ///
    QString getCachePath() const;

    Q_INVOKABLE static bool deleteDir(const QString &dirName);

    Q_INVOKABLE static bool parseOauthTokenUrl(const QString &url);

    static QString getVerison();

    Q_INVOKABLE QUrl pathTo(const QString &filename);
    Q_INVOKABLE QUrl pathPrefix(const QString &path);

    ///
    /// \brief dateParse convert datestring for js functions
    /// \param datestring
    /// \return MM,dd,yyyy,HH,mm,ss
    ///
    Q_INVOKABLE QString dateParse(const QString &datestring);
private:
    bool cacheImageFiles(const QString &remoteUrl);
    QString parseEmoticons(const QString &pattern,const QString &emoticonStr);
private:
//    QPointer<QQmlEngine> m_qmlEngine;
    Settings *m_settings;
    Emoticons *m_emoticons;
};

#endif // UTILITY_H
