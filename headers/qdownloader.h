#ifndef QDOWNLOADER_H
#define QDOWNLOADER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QFile>
#include <QStringList>
#include <QDir>
#include <QUrl>
#include <QEventLoop>
#include <QByteArray>
#include <QIODevice>

class DownloadImage : public QObject {
    Q_OBJECT
public:
    Q_INVOKABLE bool download(const QString url, const QString manga, const QString chapter, int totalCount = 0);
    Q_INVOKABLE void reset();
signals:
    void downloadComplete();
private:
    int i = 1;
};

#endif // QDOWNLOADER_H
