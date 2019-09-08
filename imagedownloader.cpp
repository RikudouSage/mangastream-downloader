#include "imagedownloader.h"

bool ImageDownloader::download(const QString url, QString manga, const QString chapter, QString savePath) {
    manga = validateFilename(manga);
    if(manga.isEmpty()) {
        emit invalidCharacters();
        return false;
    }

    QDir mangaDir(savePath + "/" + manga + "/" + chapter);
    if(!mangaDir.exists()) {
        mangaDir.mkpath(".");
    }

    QString extension = url.right(3);
    QString filename = mangaDir.absolutePath() + "/" + QString::number(i++) + "." + extension;

    path = mangaDir.absolutePath();

    QUrl dUrl(url);
    QNetworkRequest request(dUrl);
    QNetworkAccessManager mgr;

    QNetworkReply * reply = mgr.get(request);
    QEventLoop loop;

    connect(&mgr, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));
    loop.exec();

    QByteArray answer = reply->readAll();
    delete reply;

    QFile outputFile(filename);
    outputFile.open(QIODevice::WriteOnly);
    outputFile.write(answer);
    outputFile.close();

    return true;
}

void ImageDownloader::reset() {
    i = 1;
}

QString ImageDownloader::getPath() {
    return path;
}

void ImageDownloader::setPath(QString newPath) {
    if(newPath != path) {
        path = newPath;
        emit pathChanged();
    }
}

QString ImageDownloader::validateFilename(QString filename) {
    if(filename == "." || filename == "..") {
        return "";
    }
    QStringList invalid;
    MiscTools miscTools;
    if(miscTools.isWindows()) {
        invalid << "<" << ">" << ":" << "\"" << "/" << "\\" << "|" << "?" << "*";
    } else {
        invalid << "/";
    }

    foreach(QString character, invalid) {
        filename = filename.replace(character, " ");
    }

    if(miscTools.isWindows()) {
        QStringList illegal;
        illegal << "con" << "prn" << "aux" << "nul" << "com1" << "com2" << "com3" << "com4" << "com5"
                << "com6" << "com7" << "com8" << "com9" << "lpt1" << "lpt2" << "lpt3" << "lpt4"
                << "lpt5" << "lpt6" << "lpt7" << "lpt8" << "lpt9";
        if(illegal.contains(filename, Qt::CaseInsensitive)) {
            return "";
        }
        while(filename.endsWith(".") || filename.endsWith(" ")) {
            filename = filename.left(filename.length() - 1);
        }
        filename = filename.left(260); // max length on Windows
    }
    return filename;
}
