import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import QtQuick.LocalStorage 2.0
import QtQuick.Controls.Material 2.2

import com.mangastream.downloader.img 1.0
import com.mangastream.downloader.mangastream 1.0
import com.mangastream.downloader.misctools 1.0

import "qrc:/components"

ApplicationWindow {
    // custom properties
    readonly property string infoText: qsTr("Your manga was succesfully saved to %1")
    readonly property string imagesCountText: qsTr("Image %1 of %2")
    readonly property string chaptersCountText: qsTr("Chapter %1 of %2")

    property string appPath: misctools.appPath + "/manga"
    property string mangaTitle
    property string chapter
    property var db
    property var urls

    // custom functions

    function setTaskbarProgress(current, total) {
        taskbarProgress.progressVisible = true;
        taskbarProgress.maximum = total || false;
        taskbarProgress.current = current || false;
        if(current == total) {
            hideTaskbarProgress();
        }
    }

    function hideTaskbarProgress() {
        taskbarProgress.progressVisible = false;
    }

    function startLoading() {
        mainMenu.visible = false;
        loading.visible = true;
    }

    function stopLoading() {
        loading.visible = false;
        mainMenu.visible = true;
    }

    function showChaptersInfo() {
        chooseChapterLabel.visible = true;
        chooseChapterComboBox.visible = true;
        chooseChapterComboBox.currentIndexChanged();
    }

    function hideChaptersInfo() {
        chooseChapterLabel.visible = false;
        chooseChapterComboBox.visible = false;
        chooseChapterComboBox.currentIndex = 0;
        chooseChapterComboBox.currentIndexChanged();
        hideDownloadButtons();
    }

    function showDownloadButtons() {
        downloadButton.visible = true;
    }

    function hideDownloadButtons() {
        downloadButton.visible = false;
    }

    function clearProgressInfo(images, chapters) {
        hideTaskbarProgress();
        if(images !== false) {
            imagesCountLabel.text = "";
        }
        if(chapters !== false) {
            chaptersCountLabel.text = "";
        }
    }

    function setImagesProgress(index, total) {
        if(index === false) {
            clearProgressInfo(true, false);
            return;
        }
        setTaskbarProgress(index, total);
        imagesCountLabel.text = imagesCountText.arg(index).arg(total);
    }

    function setChaptersProgress(index, total) {
        if(index === false) {
            clearProgressInfo(false, true);
        }
        setTaskbarProgress(index, total);
        chaptersCountLabel.text = chaptersCountText.arg(index).arg(total);
    }

    function assignMangaList(clearCache) {
        lmodelManga.clear();
        lmodelManga.append({text: "---", value: "---"});

        startLoading();

        db.transaction(function(tx) {
            if(clearCache) {
                tx.executeSql("DELETE FROM mangalist");
            }
            var res = tx.executeSql("SELECT * FROM mangalist");
            if(!res.rows.length) {
                var mangaList = mangastream.getListOfManga();
                var url;
                var name;
                for(var i in mangaList) {
                    if(i%2 == 0) {
                        url = mangaList[i];
                    } else {
                        name = mangaList[i];
                        lmodelManga.append({text: name, value: url});
                        tx.executeSql("INSERT INTO mangalist (url, manga) VALUES (?,?)", [url, name]);
                    }
                }
            } else {
                for(var i = 0; i < res.rows.length; i++) {
                    lmodelManga.append({text: res.rows.item(i).manga, value: res.rows.item(i).url});
                }
            }
            stopLoading();
        });
    }

    function showLanguageSelection() {
        container.visible = false;
        languageSelectionContainer.visible = true;
    }

    function hideLanguageSelection() {
        container.visible = true;
        languageSelectionContainer.visible = false;
    }

    function calculatedWidth() {
        var width = 0;
        for(var i in mainMenuRow.children) {
            var className = mainMenuRow.children[i].toString();
            if(className.indexOf("QQuickToolButton") > -1) {
                var item = mainMenuRow.children[i];
                if(item.text == qsTr("Change language")) {
                    continue;
                }
                width += item.width;
            }
        }
        width += 5;
        if(width < 730) {
            width = 730;
        }

        return parseInt(width);
    }


    // setting properties

    id: root
    visible: false
    title: qsTr("MangaStream Downloader")
    width: calculatedWidth()
    minimumWidth: width
    maximumWidth: width
    height: 320
    minimumHeight: height
    maximumHeight: height

    header: ToolBar {
        id: mainMenu
        visible: false
        Row {
            id: mainMenuRow
            anchors.fill: parent
            ToolButton {
                property bool isOpen: false

                id: fileMenuMain
                text: qsTr("Settings")
                onClicked: {
                    isOpen = !isOpen;
                }
            }

            ToolButton {
                visible: fileMenuMain.isOpen
                text: qsTr("Choose manga directory")
                onClicked: {
                    selectMangaDirectoryFileDialog.open();
                }
            }

            ToolButton {
                visible: fileMenuMain.isOpen
                text: qsTr("Clear manga cache")
                onClicked: {
                    assignMangaList(true);
                }
            }

            ToolButton {
                visible: fileMenuMain.isOpen
                text: qsTr("Open manga directory")
                onClicked: {
                    if(!misctools.openDirectory(appPath)) {
                        // dir does not exist and couldn't be created
                    }
                }
            }

            ToolButton {
                visible: !fileMenuMain.isOpen
                text: qsTr("Change language")
                onClicked: {
                    showLanguageSelection();
                }
            }
        }
    }

    // invisible types

    MangaStream {
        id: mangastream
    }

    TaskbarProgress {
        id: taskbarProgress
    }

    MiscTools {
        id: misctools
        onLanguageChanged: {
            hideLanguageSelection();
            languageChangeInfoDialog.title = qsTr("Language changed");
            languageChangeInfoDialog.text = qsTr("Language was changed succesfully, please restart the app to see the changes.");
            languageChangeInfoDialog.icon = StandardIcon.Information;
            languageChangeInfoDialog.open();
        }
        onSettingsFileNotWritable: {
            hideLanguageSelection();
            languageChangeInfoDialog.title = qsTr("Language could not be changed");
            languageChangeInfoDialog.text = qsTr("Could not change language because the settings file is not writable. Try running app with administrator privileges.");
            languageChangeInfoDialog.icon = StandardIcon.Critical;
            languageChangeInfoDialog.open();
        }
        onNewVersionAvailable: {
            newVersionDialog.newVersion = newVersion;
            newVersionDialog.open();
        }
    }

    ImageDownloader {
        id: imagedownloader
        onDownloadComplete: {
            infoDialog.text = infoText.arg(imagedownloader.path);
            infoDialog.directory = imagedownloader.path;
            infoDialog.open();
        }
        onInvalidCharacters: { // should not happen
            stopLoading();
            infoDialog.text = qsTr("Error");
            infoDialog.text = qsTr("Error: Manga name contains illegal characters and cannot be saved");
            infoDialog.open();
        }
    }

    MessageDialog {
        property string directory: imagedownloader.path
        id: infoDialog
        title: qsTr("Download info")
        icon: StandardIcon.Information
        standardButtons: StandardButton.Ok | StandardButton.Open
        onAccepted: {
            if(clickedButton === StandardButton.Open) {
                misctools.openDirectory(directory);
            }
        }
    }

    MessageDialog {
        property string newVersion
        id: newVersionDialog
        title: qsTr("New version available!")
        text: qsTr("Download version %1 now?").arg(newVersion)
        icon: StandardIcon.Information
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            Qt.openUrlExternally("https://github.com/RikudouSage/mangastream-downloader");
        }
    }

    MessageDialog {
        id: languageChangeInfoDialog
        standardButtons: StandardButton.Ok
    }

    FileDialog {
        id: selectMangaDirectoryFileDialog
        title: qsTr("Choose manga directory")
        folder: shortcuts.documents
        selectFolder: true
        selectMultiple: false
        selectExisting: true
        onAccepted: {
            var url = fileUrl.toString().replace(misctools.filePrefix, "");
            appPath = url;
            db.transaction(function(tx) {
                tx.executeSql("UPDATE path SET path=?", [appPath])
            });
        }
    }

    ListModel {
        id: lmodelManga
    }

    ListModel {
        id: lmodelChapters
    }

    ListModel {
        id: lmodelLanguages
    }

    Timer {
        id: newVersionTimer
        interval: 2500
        onTriggered: {
            misctools.checkNewVersion();
        }
    }

    // start up related stuff

    Component.onCompleted: {
        startLoading();
        root.visible = true;
        db = LocalStorage.openDatabaseSync("MainDB", "1.0", "MainDB", 1000000);
        db.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS version (version)");
            tx.executeSql("CREATE TABLE IF NOT EXISTS path (path)");
            tx.executeSql("CREATE TABLE IF NOT EXISTS mangalist (url, manga)");

            var res = tx.executeSql("SELECT * FROM version");
            if(!res.rows.length) {
                tx.executeSql("INSERT INTO version (version) VALUES (1)");
            }
            res = tx.executeSql("SELECT * FROM path");
            if(!res.rows.length) { // if not stored, use the default
                tx.executeSql("INSERT INTO path (path) VALUES (?)",[appPath]);
            } else {
                appPath = res.rows.item(0).path;
            }
            assignMangaList(false);
            newVersionTimer.start();
        });
    }

    // visible stuff

    Rectangle {
        property color textColor: Material.color(Material.Grey, Material.Shade50)
        id: loading
        anchors.fill: parent
        color: Material.color(Material.Grey)
        visible: true
        z: 5000
        Label {
            id: loadingLabel
            text: qsTr("Loading...");
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 30
            color: parent.textColor
        }
        Label {
            id: imagesCountLabel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: loadingLabel.bottom
            anchors.topMargin: 20
            color: parent.textColor
        }
        Label {
            id: chaptersCountLabel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: imagesCountLabel.bottom
            anchors.topMargin: 1
            color: parent.textColor
        }
    }

    Item {
        id: languageSelectionContainer
        visible: false
        anchors.centerIn: parent
        width: container.width
        height: container.height
        Label {
            id: chooseLanguageLabel
            text: qsTr("Select language")
            font.pixelSize: 20
        }
        ComboBox {
            id: chooseLanguageComboBox
            model: lmodelLanguages
            textRole: "text"
            anchors.top: chooseLanguageLabel.top
            anchors.left: chooseLanguageLabel.right
            anchors.leftMargin: 60
            anchors.topMargin: -10
            width: chooseLanguageLabel.width
        }

        Row {
            anchors.centerIn: parent
            spacing: 20

            Button {
                id: languageSelectBackButton
                //~ Context Back as in go back
                text: "« " + qsTr("Back");
                onClicked: {
                    hideLanguageSelection();
                }
            }
            Button {
                id: languageSelectConfirmButton
                //~ Context Save as in save language preference
                text: qsTr("Save")
                onClicked: {
                    misctools.setLanguage(lmodelLanguages.get(chooseLanguageComboBox.currentIndex).language);
                }
            }
        }

        Component.onCompleted: {
            var languages = {
                en_US: "English",
                cs_CZ: "Čeština"
            };

            var currentlySelectedLanguage;
            var currentLanguage = misctools.getLanguage();

            for(var i in languages) {
                if(i == currentLanguage) {
                    currentlySelectedLanguage = i;
                }
                lmodelLanguages.append({language: i, text: languages[i]});
            }
            if(!currentlySelectedLanguage) {
                currentlySelectedLanguage = "en_US";
            }
            for(var j = 0; j < lmodelLanguages.count; j++) {
                var elem = lmodelLanguages.get(j);
                if(elem.language == currentlySelectedLanguage) {
                    chooseLanguageComboBox.currentIndex = j;
                    break;
                }
            }
        }
    }


    Item {
        id: container
        anchors.centerIn: parent
        width: parent.width - 30
        height: parent.height - 30
        Label {
            id: chooseMangaLabel
            text: qsTr("Choose manga to download:")
            font.pixelSize: 20
        }
        ComboBox {
            model: lmodelManga
            id: chooseMangaComboBox
            textRole: "text"
            anchors.top: chooseMangaLabel.top
            anchors.left: chooseMangaLabel.right
            anchors.leftMargin: 60
            anchors.topMargin: -10
            width: chooseMangaLabel.width
            onCurrentIndexChanged: {
                focus = false;
                if(currentIndex < 0) {
                    hideChaptersInfo();
                } else if(currentIndex == 0) {
                    hideChaptersInfo();
                } else if(currentIndex < lmodelManga.count) {
                    startLoading();
                    lmodelChapters.clear();
                    mangaTitle = lmodelManga.get(currentIndex).text;
                    var chapters = mangastream.getListOfChapters(lmodelManga.get(currentIndex).value);
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
                    showChaptersInfo();
                    stopLoading();
                }
            }
        }

        Label {
            id: chooseChapterLabel
            visible: false
            text: qsTr("Choose chapter:")
            anchors.top: chooseMangaLabel.bottom
            anchors.topMargin: 20
            font.pixelSize: chooseMangaLabel.font.pixelSize
        }

        ComboBox {
            id: chooseChapterComboBox
            visible: false
            model: lmodelChapters
            textRole: "text"
            anchors.left: chooseMangaComboBox.left
            anchors.top: chooseChapterLabel.top
            width: chooseMangaComboBox.width
            onCurrentIndexChanged: {
                if(currentIndex > -1 && currentIndex < lmodelChapters.count) {
                    focus = false;
                    startLoading();
                    chapter = lmodelChapters.get(currentIndex).text;
                    hideDownloadButtons();
                    urls = mangastream.getImages(lmodelChapters.get(currentIndex).link);
                    showDownloadButtons();
                    stopLoading();
                } else {
                    hideDownloadButtons();
                }
            }
        }

        Button {
            id: downloadButton
            visible: false
            text: qsTr("Download")
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: chooseChapterLabel.bottom
            anchors.topMargin: 50
            onClicked: {
                setImagesProgress(0, urls.length);
                startLoading();
                for(var i in urls) {
                    setImagesProgress(i, urls.length);
                    imagedownloader.download(urls[i], mangaTitle, chapter, appPath, urls.length);
                }
                imagedownloader.downloadComplete();
                imagedownloader.reset();
                stopLoading();
                setImagesProgress(false);
            }
        }

        Button {
            id: downloadAllButton
            visible: downloadButton.visible
            text: qsTr("Download all chapters")
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: downloadButton.bottom
            anchors.topMargin: 5
            onClicked: {
                startLoading();
                var len = lmodelChapters.count;
                setChaptersProgress(0, len);
                for(var i = 0; i < len; i++) {
                    setImagesProgress(0, 0);
                    var j = i + 1;
                    setChaptersProgress(j, len);
                    var images = mangastream.getImages(lmodelChapters.get(i).link);
                    var lenImages = images.length;
                    for(var k in images) {
                        setImagesProgress(parseInt(k) + 1, lenImages);
                        var title = lmodelChapters.get(i).text;
                        imagedownloader.download(images[k], mangaTitle, title, appPath, lenImages);
                    }
                    imagedownloader.reset();
                }
                setImagesProgress(false);
                setChaptersProgress(false);
                clearProgressInfo();
                stopLoading();
                infoDialog.text = infoText.arg(appPath+"/"+mangaTitle);
                infoDialog.directory = appPath+"/"+mangaTitle;
                infoDialog.open();
            }
        }
    }

}
