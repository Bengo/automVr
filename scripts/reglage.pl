#!/usr/bin/perl
use strict;
use warnings;
use Config::IniFiles;
use Switch;


# Permet d'envoyer un nombre de pulse sur une zone
# utilisation : ./reglage.pl zone nbPulse
# Ce script n'est pas appelé par le site ou par un batch
# il sert a reinitialiser les modules yokis au besoin
# cf les specs des modules
# nb Impulsions : fonctionnalite
# 2 : Rappel position intermédiaire
# 5 : Mémorisation de la position actuelle du volet comme position intermédiaire
# 3 : Ouverture centralisée avec un BP simples
# 4 : Fermeture centralisée avec un BP simple
# 7 : Programmation journalière de la position intermédiaire
# 8 : Programmation journalière de l'heure de fermeture
# 9 : Programmation journalière de l'heure d'ouverture
# 10: Effacement de toutes les programmations journalières
# 12: Définition de la butée électronique basse
# 14: Définition de la butée électronique haute
# 16: Effacement des butées électroniques base et haute
# 17: Supprime le mouvement inverse en cas de surcharge (bascule)
# 19: Augmente la force du moteur (bascule)
# 20: Inversion logicielle des fils montée et descente (bascule)
# 21: Verrouillage des réglages installateur (12-27)
# 22: Interdiction de la programmation journalière (bascule)
# 23: Autorisation des réglages installateur (12-27)
# 24: Désactivation des contrôles de fin de courses et de force du moteur.
# 25: Retour aux réglages d'usine
# 26: Supprime le contrôle de la force moteur (bascule)
# 27: Durée de marche des contacts illimitées

# on ouvre le fichier de configuration 
my $cfg = Config::IniFiles->new( -file => "/home/bengo/Outils/automVr/config.ini");

my @zoneChambreRdcPins = split(/,/, $cfg->val("ZonesPins","zoneChambreRdc"));
my @zoneChambresEtagePins = split(/,/, $cfg->val("ZonesPins","zoneChambresEtage"));
my @zonePieceDeViePins = split(/,/, $cfg->val("ZonesPins","zonePieceDeVie"));


my $zoneHtml="";
my $nb=1;
if ($#ARGV != 2) {
	print "Probleme de parametres \n";
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
