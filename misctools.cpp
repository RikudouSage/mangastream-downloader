#include "misctools.h"

#include <QDir>
#include <QDesktopServices>
#include <QUrl>
#include <QFile>
#include <QLocale>
#include <QSettings>
#include <QUrl>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QEventLoop>
#include <QSslSocket>

bool MiscTools::openDirectory(QString directory) {
    QDir directoryHandler(directory);
    directory = getFilePrefix()+directory;
    if(!directoryHandler.exists()) {
        if(!directoryHandler.mkpath(".")) {
            return false;
        }
    }
    return QDesktopServices::openUrl(QUrl(directory));
}

bool MiscTools::isWindows() {
#if defined(Q_OS_WIN)
    return true;
#else
    return false;
#endif
}

QString MiscTools::getAppPath() {
    return QDir::currentPath();
}

QString MiscTools::getFilePrefix() {
    if(isWindows()) {
        return "file:///";
    }
    return "file://";
}

QString MiscTools::getLanguage() {
    if(language.isEmpty()) {
        QString defaultLocale = QLocale::system().name();
        QFile settingsFile(this->settingsFile);
        if(!settingsFile.exists()) {
            return defaultLocale;
        }
        QSettings settings(settingsFile.fileName(), QSettings::IniFormat);
        settings.beginGroup("Settings");
        if(!settings.contains("Language")) {
            return defaultLocale;
        }
        QString locale = settings.value("Language", defaultLocale).toString();
        return locale;
    }
    return language;
}

void MiscTools::setLanguage(QString language) {
    QSettings settings(this->settingsFile, QSettings::IniFormat);
    if(!settings.isWritable()) {
        emit settingsFileNotWritable();
        return;
    }
    settings.beginGroup("Settings");
    settings.setValue("Language", language);
    emit languageChanged();
}

void MiscTools::checkNewVersion()
{
    QNetworkAccessManager mgr;
    QNetworkRequest request(QUrl("http://www.chrastecky.cz/mangastream-downloader/version.txt"));
    QNetworkReply *reply = mgr.get(request);
    QEventLoop loop;
    connect(&mgr, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));
    loop.exec();
    QString answer = reply->readAll();
    delete reply;
    QVersionNumber remoteVersion = QVersionNumber::fromString(answer);
    if(version < remoteVersion) {
        emit newVersionAvailable(remoteVersion.toString());
    }
}

