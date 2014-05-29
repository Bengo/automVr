#!/usr/bin/perl
use strict;
use warnings;
use Config::IniFiles;
use Switch;

my ($zoneHtml, $position) = @ARGV;
 
if (not defined $zoneHtml or not defined $position) {
	die "Probleme de parametres\n";
}

# on ouvre le fichier de configuration 
my $cfg = Config::IniFiles->new( -file => "/home/bengo/Outils/automVr/config.ini");

my @zoneChambreRdcPins = split(/,/, $cfg->val("ZonesPins","zoneChambreRdc"));
my @zoneChambresEtagePins = split(/,/, $cfg->val("ZonesPins","zoneChambresEtage"));
my @zonePieceDeViePins = split(/,/, $cfg->val("ZonesPins","zonePieceDeVie"));

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

#fonction permettant d'envoyer les commandes aux volets
sub agirVolet {
	my $nbimpulsions = shift;
	my $i=0;
	for($i=0 ; $i<$nbimpulsions ; $i++){		
		#on met a 1 les pins
		foreach my $pin (@pins){
			system("/usr/local/bin/gpio write $pin 1;");
		}
		#on attend
		system("sleep 0.1");
		#on met a 0 les pins
		foreach my $pin (@pins){
			system("/usr/local/bin/gpio write $pin 0;");
		}
		#on attend
		system("sleep 0.1");
	}
	return;

}

switch($position) {
	case "haut" {
		agirVolet(3);
		system("sleep 1.5");
	}
	case "bas" {
		agirVolet(4);
		system("sleep 1.5");
	}
	case "intermediaire" {
		#on leve les volets
		agirVolet(3);
		#on attend que les volets soient leves
		system("sleep 18");
		#on baisse les volets
		agirVolet(4);
		#on attend d'atteindre le position intermediaire
		system("sleep 8.8");
		#on stop le mouvement
		agirVolet(1);
		#on attend
		system("sleep 1.5");
	}
}









