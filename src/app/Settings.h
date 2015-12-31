#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QStringList>
#include <QVariant>

class QSettings;
class Settings : public QObject
{
    Q_OBJECT
//    Q_PROPERTY(QString accessToken READ accessToken WRITE setAccessToken NOTIFY accessTokenChanged)
//    Q_PROPERTY(QString expiresData READ expiresData WRITE setExpiresData NOTIFY expiresDataChanged)
//    Q_PROPERTY(QString uid READ uid WRITE setUid NOTIFY uidChanged)
//    Q_PROPERTY(QString refreshToken READ refreshToken WRITE setRefreshToken NOTIFY refreshTokenChanged)
public:
    static Settings *instance();
    virtual ~Settings();

    void setValue(const QString &key, const QVariant &value);
    QVariant getValue(const QString &key, const QVariant &defaultValue = QVariant());

//    QString accessToken() const;
//    void setAccessToken(const QString &value);

//    QString expiresData() const;
//    void setExpiresData(const QString &value);

//    QString uid() const;
//    void setUid(const QString &value);

//    QString refreshToken() const;
//    void setRefreshToken(const QString &value);

signals:
//    void accessTokenChanged();
//    void expiresDataChanged();
//    void uidChanged();
//    void refreshTokenChanged();

public slots:

private:
    explicit Settings(QObject *parent = 0);

private:
    QSettings *m_settings;
//    QString m_accessToken;
//    QString m_expiresData;
//    QString m_uid;
//    QString m_refreshToken;

};
#endif // SETTINGS_H
