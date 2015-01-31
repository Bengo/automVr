var express = require('express');
var fs = require('fs');
var ini = require('ini');
var exec = require('child_process').exec;


var app = express();

var static = express();
//tout le repertoire public est servi en static
static.use(express.static(__dirname + '/public'));
var api = express();
var config = ini.parse(fs.readFileSync('../config.ini', 'utf-8'))

function agir_volets(zone,position){
	var exec_volets = exec('../scripts/volets.pl '+zone+' '+position,
							function (error, stdout, stderr) {});
}

api.get('/options', function(req, res) {
    res.setHeader('Content-Type', 'text/plain');
    res.end(JSON.stringify(config));
});

api.get('/volets/:zone/:position', function(req, res) {
	agir_volets(req.params.zone,req.params.position);
	res.setHeader('Content-Type', 'text/plain');
    res.end("En cours ...");
});

app.use('/api',api);
app.use('/',static);

app.listen(80);
