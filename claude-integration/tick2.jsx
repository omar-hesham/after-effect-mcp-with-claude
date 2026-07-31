try { if ($.global.mcpCheckTaskId != null) { app.cancelTask($.global.mcpCheckTaskId); $.global.mcpCheckTaskId = null; } } catch(e) {}
var autoOn = false;
try { autoOn = autoRunCheckbox.value; } catch(e) { autoOn = false; }
if (autoOn) {
try {
  var f = new File(getCommandFilePath());
  if (f.exists) {
    f.encoding = "UTF-8"; f.open("r"); var content = f.read(); f.close();
    if (content) {
      var d = JSON.parse(content);
      var key = d.commandId || d.timestamp || "";
      if (key && key !== $.global.myAeLastCmd) {
        $.global.myAeLastCmd = key;
        currentCommandId = d.commandId || "";
        executeCommand(d.command, d.args || {});
      }
    }
  }
} catch(e2) {}
}
