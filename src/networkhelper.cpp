#include "networkhelper.h"
#include <QtCore>

NetworkHelper::NetworkHelper(QObject *parent) :
    QObject(parent)
{
    this->_imgFolder = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
    this->mgrUpload = new QNetworkAccessManager(this);
}

void NetworkHelper::uploadImgStatus(const QString &token, const QString &status, const QString &fileUrl)
{
    QUrl url("https://upload.api.weibo.com/2/statuses/upload.json?access_token=" + token /* + "&status=" + status*/);
    QFileInfo imgInfo(fileUrl);
//    qDebug() << "file path: " << imgInfo.filePath();

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    QHttpPart textPart;
    textPart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("text/plain"));
    textPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"status\""));
    textPart.setBody(status.toUtf8());

    QHttpPart imagePart;
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("image/" + imgInfo.suffix()));
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader,
                        QVariant("form-data; name=\"pic\"; filename=" + imgInfo.fileName()));
    QFile *file = new QFile(fileUrl);
    bool isOpen = file->open(QIODevice::ReadOnly);
    qDebug() << "file open? " << isOpen;
    imagePart.setBodyDevice(file);
    file->setParent(multiPart); // we cannot delete the file now, so delete it with the multiPart

    multiPart->append(textPart);
    multiPart->append(imagePart);

    QNetworkRequest request(url);
//    request.setHeader(QNetworkRequest::ContentTypeHeader, "multipart/form-data");
    this->replyUpload = this->mgrUpload->post(request, multiPart);
    multiPart->setParent(replyUpload); // delete the multiPart with the reply
    connect(replyUpload, SIGNAL(finished()), this, SLOT(replyUploadFinish()));
}

void NetworkHelper::replyUploadFinish()
{
//    qDebug() << "upload reply: " << replyUpload->readAll();
    emit this->uploadFinished(QString(replyUpload->readAll()));
}
