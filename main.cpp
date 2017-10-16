#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>
#include <QtQml>
#include <QObject>

#include "imagedownloader.h"
#include "mangastream.h"
#include "misctools.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    MiscTools tools;

    QTranslator qTranslator;
    qTranslator.load(tools.getLanguage(), ":/translations");
    app.installTranslator(&qTranslator);

    QQmlApplicationEngine engine;

    qmlRegisterType<ImageDownloader>("com.mangastream.downloader.img", 1, 0, "ImageDownloader");
    qmlRegisterType<MangaStream>("com.mangastream.downloader.mangastream", 1, 0, "MangaStream");
    qmlRegisterType<MiscTools>("com.mangastream.downloader.misctools", 1, 0, "MiscTools");

    engine.load(QUrl(QLatin1String("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
