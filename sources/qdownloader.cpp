#include "headers/qdownloader.h"
#include <QDebug>

bool DownloadImage::download(const QString url, const QString manga, const QString chapter, int totalCount) {
    if(totalCount > 0) {
        qDebug() << "Image "+QString::number(i)+" of "+QString::number(totalCount);
    }
    QString currentPath = QDir::currentPath();
    QDir mangaDir(currentPath+"/manga/"+manga+"/"+chapter);
    if(!mangaDir.exists()) {
        mangaDir.mkpath(".");
    }

    QString extension = url.right(3);

    QString filename = mangaDir.absolutePath()+"/"+QString::number(i++)+"."+extension;

    //qDebug() << filename;

    QUrl dUrl(url);
    QNetworkRequest request(dUrl);
    QNetworkAccessManager mgr;

    QNetworkReply *reply = mgr.get(request);

    QEventLoop eventLoop;

    QObject::connect(&mgr, SIGNAL(finished(QNetworkReply*)), &eventLoop, SLOT(quit()));
    eventLoop.exec();

    QByteArray answer = reply->readAll();

    QFile output(filename);
    output.open(QIODevice::WriteOnly);
    output.write(answer);
    output.close();

    return true;
}

void DownloadImage::reset() {
    i = 1;
}
