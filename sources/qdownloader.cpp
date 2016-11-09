#include "headers/qdownloader.h"

bool DownloadImage::download(const QString url, const QString manga, const QString chapter, const QString savePath, int totalCount) {

    if(IS_DEBUG) {
        if(totalCount > 0) {
            qDebug() << "Image "+QString::number(i)+" of "+QString::number(totalCount);
        }
    }

    QString currentPath = savePath;
    QDir mangaDir(currentPath+"/"+manga+"/"+chapter);
    if(!mangaDir.exists()) {
        mangaDir.mkpath(".");
    }

    QString extension = url.right(3);

    QString filename = mangaDir.absolutePath()+"/"+QString::number(i++)+"."+extension;

    path = mangaDir.absolutePath();

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

QString DownloadImage::getPath() {
    return path;
}
