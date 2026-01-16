import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root

  property var pluginApi: null

  property var valueFolders: pluginApi?.pluginSettings?.folders || pluginApi?.manifest?.metadata?.defaultSettings?.folders || []
  property string currentFolder: Settings.data.wallpaper.directory || ""

  spacing: Style.marginXL

  Component.onCompleted: {
    // Добавить текущую папку в список если её там нет
    if (currentFolder && !valueFolders.includes(currentFolder)) {
      valueFolders = [currentFolder, ...valueFolders];
    }
    Logger.i("WallpaperSwitcher", "Settings UI loaded, folders:", JSON.stringify(valueFolders));
  }

  NLabel {
    label: "Wallpaper Folders"
    description: "Add folders containing your wallpapers"
  }

  ColumnLayout {
    Layout.fillWidth: true
    spacing: Style.marginS

    Repeater {
      model: root.valueFolders

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        NIcon {
          icon: "folder"
        }

        NText {
          Layout.fillWidth: true
          text: modelData
          elide: Text.ElideMiddle
          color: Color.mOnSurface
        }

        NButton {
          icon: "x"
          onClicked: root.removeFolder(index)
        }
      }
    }

    NText {
      visible: root.valueFolders.length === 0
      text: "No folders added"
      color: Color.mOnSurfaceVariant
    }
  }
  Item { Layout.preferredHeight: Style.marginXL }

  NTextInput {
    id: newFolderInput
    Layout.fillWidth: true
    label: "Add Folder"
    description: "Enter the full path to a wallpaper folder"
    placeholderText: "/path/to/wallpapers"
  }

  NButton {
    text: "Add Folder"
    icon: "add"
    onClicked: {
      const path = newFolderInput.text.trim();
      if (path && !root.valueFolders.includes(path)) {
        root.valueFolders = [...root.valueFolders, path];
        newFolderInput.text = "";
        Logger.i("WallpaperSwitcher", "Added folder:", path);
        root.saveSettings();
      }
    }
  }

  Item { Layout.preferredHeight: Style.marginXL }

  NLabel {
    label: "IPC Commands"
    description: "Use these commands to control the plugin from terminal"
  }

  Rectangle {
    Layout.fillWidth: false
    Layout.preferredWidth: 500 * Style.uiScaleRatio * 1.2
    Layout.fillHeight: false
    Layout.preferredHeight: infoCol.implicitHeight + Style.marginM * 2
    color: Color.mSurfaceVariant
    radius: Style.radiusM

    ColumnLayout {
      id: infoCol
      anchors {
        fill: parent
        margins: Style.marginM
      }
      spacing: Style.marginS



      NText {
        Layout.fillWidth: true
        text: "qs -c noctalia-shell ipc call plugin:wallpaper-folder-switcher next"
        font.pointSize: Style.fontSizeXS
        font.family: Settings.data.ui.fontFixed
        color: Color.mOnSurfaceVariant
        wrapMode: Text.WrapAnywhere
      }

      NText {
        Layout.fillWidth: true
        text: "qs -c noctalia-shell ipc call plugin:wallpaper-folder-switcher prev"
        font.pointSize: Style.fontSizeXS
        font.family: Settings.data.ui.fontFixed
        color: Color.mOnSurfaceVariant
        wrapMode: Text.WrapAnywhere
      }

      NText {
        Layout.fillWidth: true
        text: "qs -c noctalia-shell ipc call plugin:wallpaper-folder-switcher toggle"
        font.pointSize: Style.fontSizeXS
        font.family: Settings.data.ui.fontFixed
        color: Color.mOnSurfaceVariant
        wrapMode: Text.WrapAnywhere
      }
    }
  }

  function removeFolder(idx) {
    const newFolders = [...root.valueFolders];
    newFolders.splice(idx, 1);
    root.valueFolders = newFolders;
    Logger.i("WallpaperSwitcher", "Removed folder at index:", idx);
    root.saveSettings();
  }

  function saveSettings() {
    if (!pluginApi) {
      Logger.e("WallpaperSwitcher", "Cannot save settings: pluginApi is null");
      return;
    }

    pluginApi.pluginSettings.folders = root.valueFolders;
    pluginApi.saveSettings();

    Logger.i("WallpaperSwitcher", "Settings saved successfully");
  }
}
