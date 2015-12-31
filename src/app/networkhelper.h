#ifndef NETWORKHELPER_H
#define NETWORKHELPER_H

#include <QObject>
#include <QtCore>
#include <QtNetwork>

class NetworkHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString imgFolder READ imgFolder)

public:
    explicit NetworkHelper(QObject *parent = 0);

signals:
    void uploadFinished(QString response);

public slots:
    void uploadImgStatus(const QString &token, const QString &status, const QString &fileUrl);

protected:
    QString imgFolder() { return _imgFolder; }

    QString _imgFolder;

private:
    QNetworkAccessManager *mgrUpload;
    QNetworkReply *replyUpload;

private slots:
    void replyUploadFinish();

};

#endif // NETWORKHELPER_H
