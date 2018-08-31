fl.runScript(fl.scriptURI+"/../shared/Global.jsfl");

fl.outputPanel.clear();
var doc = fl.getDocumentDOM();
trace(doc.exportPublishProfileString(doc.currentPublishProfile));