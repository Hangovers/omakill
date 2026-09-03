import QtQuick
import Quickshell
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.hangovers.omakill"

  // Absolute path of this plugin's bin/ dir (helpers ship with the repo).
  readonly property string binDir: decodeURIComponent(
    String(Qt.resolvedUrl(".")).replace(/^file:\/\//, "").replace(/\/$/, "")
  ) + "/bin"

  readonly property bool opened: panelLoader.item
    ? panelLoader.item.opened === true
    : false
  readonly property bool popoutSwitchClosing: panelLoader.item
    ? panelLoader.item.popoutSwitchClosing === true
    : false

  function open() {
    if (panelLoader.item) panelLoader.item.open()
  }

  function close() {
    if (panelLoader.item) panelLoader.item.close()
  }

  function toggle() {
    if (panelLoader.item) panelLoader.item.toggle()
  }

  function closeForPopoutSwitch() {
    if (panelLoader.item) panelLoader.item.closeForPopoutSwitch()
  }

  function injectPanel() {
    if (!panelLoader.item) return
    panelLoader.item.bar = root.bar
    panelLoader.item.anchorItem = button
    panelLoader.item.hostWidget = root
    panelLoader.item.binDir = root.binDir
  }

  function runAction(action) {
    // Close the panel first so the summoned menus take focus cleanly.
    root.close()
    if (action === "click") {
      Quickshell.execDetached(["omarchy-notification-send", "Kill", "Click a window to kill — ESC to cancel", "-g", "󰍉"])
      Quickshell.execDetached(["hyprctl", "kill"])
    } else if (action === "window") {
      Quickshell.execDetached([root.binDir + "/omarchy-kill-window"])
    } else if (action === "process") {
      Quickshell.execDetached([root.binDir + "/omarchy-kill-process"])
    } else if (action === "tasks") {
      Quickshell.execDetached(["omarchy-launch-tui", "btop"])
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰭌"
    tooltipText: "Omakill — force-close apps"
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.LeftButton) root.toggle()
    }
  }
}
