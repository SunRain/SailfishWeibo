#ifndef UTIL_H
#define UTIL_H

#include <QObject>
#include <QSettings>
#include <QQmlEngine>
#include <QPointer>

class Util : public QObject
{
    Q_OBJECT
public:
    static Util *getInstance();
    virtual ~Util();
    
    void setEngine(QQmlEngine* engine);
    
public:
    Q_INVOKABLE void setValue(const QString &key, const QVariant &value);
    Q_INVOKABLE QVariant getValue(const QString &key, const QVariant defaultValue = QVariant());
    Q_INVOKABLE bool saveToCache(const QString &remoteUrl, const QString &dirName, const QString &fileName);
    
    //解析微博内容，替换表情/链接等
    Q_INVOKABLE QString parseWeiboContent(const QString &weiboContent,
                                          const QString &contentColor, 
                                          const QString &userColor,
                                          const QString &linkColor);
    ///解析图片链接，返回本地缓存/远程链接
    Q_INVOKABLE QString parseImageUrl(const QString &remoteUrl);
    Q_INVOKABLE void saveRemoteImage(const QString &remoteUrl);
signals:
    
public slots:
    
private:
    explicit Util(QObject *parent = 0);
    bool cacheImageFiles(const QString &remoteUrl);
    QString parseEmoticons(const QString &pattern,const QString &emoticonStr);
private:
    QPointer<QSettings> m_Settings;
    QPointer<QQmlEngine> m_Engine;
    QVariantMap m_Map;
};

#endif // UTIL_H
