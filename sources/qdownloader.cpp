#include "headers/qdownloader.h"
#include "headers/misctools.h"

bool DownloadImage::download(const QString url, QString manga, const QString chapter, const QString savePath, int totalCount) {

    if(IS_DEBUG) {
        if(totalCount > 0) {
            qDebug() << "Image "+QString::number(i)+" of "+QString::number(totalCount);
        }
    }

    QString currentPath = savePath;
    manga = validateFilename(manga);
    if(manga.isEmpty()) {
        emit invalidCharacters();
        return false;
    }
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

QString DownloadImage::validateFilename(QString filename) {
    if(filename == "." || filename == "..") {
        return "";
    }
    QStringList invalid;
    MiscTools miscTools;
    if(!miscTools.isWindows()) {
        invalid << "/";
    } else {
        invalid << "<" << ">" << ":" << "\"" << "/" << "\\" << "|" << "?" << "*";
    }
    foreach(QString character, invalid) {
        filename = filename.replace(character, " ");
    }
    if(miscTools.isWindows()) {
        QStringList illegal;
        illegal << "con" << "prn" << "aux" << "nul" << "com1" << "com2" << "com3" << "com4" << "com5"
                << "com6" << "com7" << "com8" << "com9" << "lpt1" << "lpt2" << "lpt3" << "lpt4"
                << "lpt5" << "lpt6" << "lpt7" << "lpt8" << "lpt9";
        if(illegal.contains(filename,Qt::CaseInsensitive)) {
            return "";
        }
        while(filename.endsWith(".") || filename.endsWith(" ")) {
            filename = filename.left(filename.length() - 1);
        }
        filename = filename.left(260); // max path length for Windows
    }
    return filename;
}
