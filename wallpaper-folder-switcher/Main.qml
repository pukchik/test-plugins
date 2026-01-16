import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Services.UI

Item {
  id: root
  property var pluginApi: null

  readonly property var folders: pluginApi?.pluginSettings?.folders || []
  readonly property string currentFolder: Settings.data.wallpaper.directory || ""

  function getCurrentIndex() {
    if (folders.length === 0) return -1;
    return folders.indexOf(currentFolder);
  }

  function setFolder(path) {
    Settings.data.wallpaper.directory = path;
    Logger.i("WallpaperSwitcher", "IPC: Changed wallpaper directory to: " + path);
    ToastService.showNotice("Folder: " + path.split("/").pop());
  }

  IpcHandler {
    target: "plugin:wallpaper-folder-switcher"

    function next() {
      if (root.folders.length === 0) {
        ToastService.showError("No folders configured");
        return;
      }
      var idx = root.getCurrentIndex();
      var nextIdx = (idx + 1) % root.folders.length;
      root.setFolder(root.folders[nextIdx]);
    }

    function prev() {
      if (root.folders.length === 0) {
        ToastService.showError("No folders configured");
        return;
      }
      var idx = root.getCurrentIndex();
      var prevIdx = idx <= 0 ? root.folders.length - 1 : idx - 1;
      root.setFolder(root.folders[prevIdx]);
    }

    function set(folderPath: string) {
      if (folderPath && root.folders.includes(folderPath)) {
        root.setFolder(folderPath);
      } else {
        ToastService.showError("Folder not in list: " + folderPath);
      }
    }

    function toggle() {
      if (pluginApi) {
        pluginApi.withCurrentScreen(screen => {
          pluginApi.openPanel(screen);
        });
      }
    }
  }
}
