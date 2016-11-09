import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.2
import QtQuick.LocalStorage 2.0

import cz.chrastecky.img 1.0
import cz.chrastecky.mangastream 1.0
import cz.chrastecky.misc 1.0

import "qrc:/qml/components"

ApplicationWindow {
    readonly property string infoText: qsTr("Your manga was successfully saved to %1")
    readonly property string imagesCountText: qsTr("Image %1 of %2")

    property int marginSize: 30

    property var urls
    property var db

    property string mangaTitle
    property string chapter
    property string appPath: misctools.appPath+"/manga"

    visible: true
    width: 640
    minimumWidth: 640
    maximumWidth: 640

    height: 240
    minimumHeight: 240
    maximumHeight: 240

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("&Choose manga directory")
                onTriggered: {
                    filedialog.open();
                }
            }
        }
    }

    FileDialog {
        id: filedialog
        title: qsTr("Choose manga directory")
        folder: shortcuts.documents
        selectFolder: true
        selectMultiple: false
        selectExisting: true
        onAccepted: {
            var url = fileUrl.toString().replace(misctools.filePrefix,"");
            appPath = url;
            db.transaction(function(tx) {
                tx.executeSql("UPDATE path SET path='"+url+"'");
            });
        }
    }

    function startLoading() {
        loading.visible = true;
    }

    function stopLoading() {
        loading.visible = false;
    }

    function progress(index, total) {
        if(index === false) {
            imagescount.text = "";
            return;
        }

        imagescount.text = imagesCountText.arg(index).arg(total);
    }

    title: qsTr("MangaStream downloader")
    Label {
        id: chooselabel
        text: qsTr("Choose manga to download:")
        x: marginSize
        y: marginSize
        font.pixelSize: 25
    }

    Rectangle {
        id: loading
        anchors.fill: parent
        color: "white"
        visible: true
        z: 5000
        Label {
            text: qsTr("Loading...")
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height / 2 - marginSize / 2
            font.pixelSize: 20
        }
        Label {
            id: imagescount
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height / 2 + marginSize / 2
        }
    }

    ComboBox {
        model: lmodel
        textRole: "text"
        x: chooselabel.x + chooselabel.width + marginSize
        y: marginSize + 5
        onCurrentIndexChanged: {
            if(typeof lmodel.get(currentIndex).value !== "undefined") {
                startLoading();
                lmodelChapters.clear();
                mangaTitle = lmodel.get(currentIndex).text;
                var chapters = mangastream.getListOfChapters(lmodel.get(currentIndex).value);
                var url;
                var name;
                for(var i in chapters) {
                    if(i%2 == 0) {
                        url = chapters[i];
                    } else {
                        name = chapters[i];
                        lmodelChapters.append({text: name, link: url});
                    }
                }
                chapterlabel.visible = true;
                selectChapters.visible = true;
                selectChapters.currentIndexChanged();
                stopLoading();
            }
        }
    }

    Label {
        id: chapterlabel
        text: qsTr("Choose chapter: ")
        x: marginSize
        y: chooselabel.y + chooselabel.height + marginSize
        font.pixelSize: 25
        visible: false
    }

    ImageDownloader {
        id: downloader
        onDownloadComplete: {
            info.text = infoText.arg(downloader.path);
            info.open();
        }
    }

    MessageDialog {
        id: info
        title: qsTr("Download info")
        icon: StandardIcon.Information
        standardButtons: StandardButton.Ok | StandardButton.Open
        onAccepted: {
            if(clickedButton == StandardButton.Open) {
                misctools.openDirectory(downloader.path);
            }
        }
    }

    MangaStream {
        id: mangastream
    }

    MiscTools {
        id: misctools
    }

    ComboBox {
        id: selectChapters
        model: lmodelChapters
        textRole: "text"
        x: chapterlabel.x + chapterlabel.width + marginSize
        y: chapterlabel.y + 5
        visible: false
        onCurrentIndexChanged: {
            if(typeof lmodelChapters.get(currentIndex).link != "undefined" && lmodelChapters.get(currentIndex).text != "undefined") {
                startLoading();
                chapter = lmodelChapters.get(currentIndex).text;
                downloadButton.visible = false;
                urls = mangastream.getImages(lmodelChapters.get(currentIndex).link);
                downloadButton.visible = true;
                stopLoading();
            }
        }
    }

    NewButton {
        id: downloadButton
        visible: false
        paddingLeftRight: 30
        text: qsTr("Download")
        x: marginSize
        y: selectChapters.y + selectChapters.height + marginSize
        font.pixelSize: 17
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            progress(0, urls.length);
            startLoading();
            for(var i in urls) {
                progress(i, urls.length);
                downloader.download(urls[i], mangaTitle, chapter, appPath, urls.length);
            }
            downloader.downloadComplete();
            downloader.reset();
            stopLoading();
            progress(false);
        }
    }

    ListModel {
        id: lmodel
    }

    ListModel {
        id: lmodelChapters
    }

    Component.onCompleted: {
        startLoading();
        db = LocalStorage.openDatabaseSync("MainDB","1.0","MainDB",1000000);
        db.transaction(function(tx){
            tx.executeSql("CREATE TABLE IF NOT EXISTS version (version)");
            tx.executeSql("CREATE TABLE IF NOT EXISTS path (path)")
            var res = tx.executeSql("SELECT * FROM version");
            if(!res.rows.length) {
                tx.executeSql("INSERT INTO version (version) VALUES (1)");
            }
            res = tx.executeSql("SELECT * FROM path");
            if(!res.rows.length) {
                tx.executeSql("INSERT INTO path (path) VALUES (?)",[appPath]);
            } else {
                appPath = res.rows.item(0).path;
            }
        });
        var mangaList = mangastream.getListOfManga();
        lmodel.append({text: "---", value: "---"});

        var url;
        var name;
        for(var i in mangaList) {
            if(i % 2 == 0) {
                url = mangaList[i];
            } else {
                name = mangaList[i];
                lmodel.append({text: name, value: url});
            }
        }
        stopLoading();
    }
}
