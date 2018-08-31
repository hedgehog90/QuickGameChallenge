fl.runScript(fl.scriptURI+"/../shared/Global.jsfl");

fl.outputPanel.clear();

fl.getDocumentDOM().selection.forEach(function(e) {
	resetRegistrationPoint(e);
});