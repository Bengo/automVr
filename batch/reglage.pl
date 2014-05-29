#!/usr/bin/perl
use strict;
use warnings;
use Config::IniFiles;
use Switch;

# on ouvre le fichier de configuration 
my $cfg = Config::IniFiles->new( -file => "/home/bengo/Outils/automVr/config.ini");

my @zoneChambreRdcPins = split(/,/, $cfg->val("ZonesPins","zoneChambreRdc"));
my @zoneChambresEtagePins = split(/,/, $cfg->val("ZonesPins","zoneChambresEtage"));
my @zonePieceDeViePins = split(/,/, $cfg->val("ZonesPins","zonePieceDeVie"));


my $zoneHtml="";
my $nb=1;
if ($#ARGV != 2) {
	print "Probleme de parametres";
}
else {
	$zoneHtml=$ARGV[0];
	$nb=$ARGV[1];
}

my @pins = ();
switch($zoneHtml) {
	case "generale" {
		push(@pins, @zoneChambreRdcPins);
		push(@pins, @zoneChambresEtagePins);
		push(@pins, @zonePieceDeViePins);
	}
	case "pdv" {
		push(@pins, @zonePieceDeViePins);
	}
	case "chrdc" {
		push(@pins, @zoneChambreRdcPins);
	}
	case "etage" {
		push(@pins, @zoneChambresEtagePins);
	}
}

#on met en mode out les pins
foreach my $pin (@pins){
	system("gpio mode $pin out;");
}

#on fait 5 impulsions sur les pins activees
my $i=0;
for($i=0 ; $i<$nb ; $i++){		
	#on met a 1 les pins
	foreach my $pin (@pins){
		system("/usr/local/bin/gpio write $pin 1;");
	}
	#on attend
	system("sleep 0.3");
	#on met a 0 les pins
	foreach my $pin (@pins){
		system("/usr/local/bin/gpio write $pin 0;");
	}
	#on attend
	system("sleep 0.3");
}