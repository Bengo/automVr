var express = require('express');
var fs = require('fs');
var ini = require('ini');
var exec = require('child_process').exec;


var app = express();
var static = express();

//tout le repertoire public est servi en static
static.use(express.static(__dirname + '/public'));
var api = express();


function agir_volets(zone,position){
	exec('../scripts/volets.pl '+zone+' '+position,	function (error, stdout, stderr) {});
}

function mode_fete_actif(actif, mode_fete_result){
	if(JSON.parse(actif)) {
		exec('../scripts/volets.pl option modeFeteOn',	function (error, stdout, stderr) {});
		return "actif";
	} else {
		exec('../scripts/volets.pl option modeFeteOff',	function (error, stdout, stderr) {});
		return "inactif";
	}
}

api.get('/options', function(req, res) {
    var config = ini.parse(fs.readFileSync('../config.ini', 'utf-8'))
    res.setHeader('Content-Type', 'text/plain');
    res.end(JSON.stringify(config));
});

api.get('/options/modefe/:actif', function(req, res) {
	var mode_fete_result=mode_fete_actif(req.params.actif, mode_fete_result);
    res.setHeader('Content-Type', 'text/plain');
    res.end("mode fete mis a "+mode_fete_result);
});

api.get('/volets/:zone/:position', function(req, res) {
	agir_volets(req.params.zone,req.params.position);
	res.setHeader('Content-Type', 'text/plain');
    res.end("En cours ...");
});

app.use('/api',api);
app.use('/',static);

app.listen(80);
