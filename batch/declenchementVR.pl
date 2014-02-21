#!/usr/bin/perl
use strict;
use warnings;
use Config::IniFiles;
use Time::Local;

# on ouvre le fichier de configuration 
my $cfg = Config::IniFiles->new( -file => "/home/bengo/Outils/automVr/config.ini");

my $modeFete = $cfg->val("ModeFete","modeFete");


#monter auto
my $zoneChambreRdcMonteeAuto = $cfg->val("ZonesMonteeAuto","zoneChambreRdc");
my $zoneChambresEtageMonteeAuto = $cfg->val("ZonesMonteeAuto","zoneChambresEtage");
my $zonePieceDeVieMonteeAuto = $cfg->val("ZonesMonteeAuto","zonePieceDeVie");

#descente autoF
my $zoneChambreRdcDescenteAuto = $cfg->val("ZonesDescenteAuto","zoneChambreRdc");
my $zoneChambresEtageDescenteAuto = $cfg->val("ZonesDescenteAuto","zoneChambresEtage");
my $zonePieceDeVieDescenteAuto = $cfg->val("ZonesDescenteAuto","zonePieceDeVie");

my @zoneChambreRdcPins = split(/,/, $cfg->val("ZonesPins","zoneChambreRdc"));
my @zoneChambresEtagePins = split(/,/, $cfg->val("ZonesPins","zoneChambresEtage"));
my @zonePieceDeViePins = split(/,/, $cfg->val("ZonesPins","zonePieceDeVie"));


# heure de lever/coucher du jour
my @leverJour = split(/:/, $cfg->val("Ephemeride","leverSoleil"));
my @coucherJour = split(/:/, $cfg->val("Ephemeride","coucherSoleil"));

my (undef, $min, $heure, $jour, $mois, $annee, undef, undef, undef) = localtime(time); 
my $timeActuel = timelocal("0", $min, $heure, $jour, $mois, $annee);

my $timeLeverJour = timelocal("0", $leverJour[1], $leverJour[0]+1, $jour, $mois, $annee);

my $timeCoucherJour = timelocal("0", $coucherJour[1], $coucherJour[0]-1, $jour, $mois, $annee);

# test si on doit lever les volets
my @borneInfLever = split(/:/, $cfg->val("Scenario","borneInfLever"));
my $timeInflever = timelocal("0", $borneInfLever[1], $borneInfLever[0], $jour, $mois, $annee);

my @borneSupLever = split(/:/, $cfg->val("Scenario","borneSupLever"));
my $timeSuplever = timelocal("0", $borneSupLever[1], $borneSupLever[0], $jour, $mois, $annee);


# si le lever de soleil a lieu avant l'intervalle
if($timeLeverJour<$timeInflever) {
	if($timeActuel == $timeInflever) {
		monteeAutoVolets();	
	}
# si le lever de soleil a lieu dans l'intervalle
} elsif($timeLeverJour>=$timeInflever && $timeLeverJour<=$timeSuplever){
	if($timeActuel == $timeLeverJour) {
		monteeAutoVolets();	
	}
#le lever de soleil a lieu apres l'intervalle
} else {
	if($timeActuel == $timeSuplever) {
		monteeAutoVolets();	
	}	
}

# test si on doit baisser les volets
my @borneInfCoucher = split(/:/, $cfg->val("Scenario","borneInfCoucher"));
my $timeInfCoucher = timelocal("0", $borneInfCoucher[1], $borneInfCoucher[0], $jour, $mois, $annee);

my @borneSupCoucher = split(/:/, $cfg->val("Scenario","borneSupCoucher"));
my $timeSupCoucher = timelocal("0", $borneSupCoucher[1], $borneSupCoucher[0], $jour, $mois, $annee);

# si le coucher de soleil a lieu avant l'intervalle
if($timeCoucherJour<$timeInfCoucher) {
	if($timeActuel == $timeInfCoucher) {
		descenteAutoVolets();	
	}
# si le coucher de soleil a lieu dans l'intervalle
} elsif($timeCoucherJour>=$timeInfCoucher && $timeCoucherJour<=$timeSupCoucher){
	if($timeActuel == $timeCoucherJour) {
		descenteAutoVolets();
	}
#le coucher de soleil a lieu apres l'intervalle
} else {
	if($timeActuel == $timeSupCoucher) {
		descenteAutoVolets();	
	}	
}

sub monteeAutoVolets {
	print("Montee Auto");
	#si le mode fete n'est pas actif
	if($modeFete eq "off") {
		#on recupere les zones actives	
		my @pinsAuto = ();
		if($zoneChambreRdcMonteeAuto eq "on") {
			push(@pinsAuto, @zoneChambreRdcPins);		
		}
		if($zoneChambresEtageMonteeAuto eq "on") {
			push(@pinsAuto, @zoneChambresEtagePins);		
		}
		if($zonePieceDeVieMonteeAuto eq "on") {
			push(@pinsAuto, @zonePieceDeViePins);
		}

		#on met en mode out les pins
		foreach my $pin (@pinsAuto){
			system("/usr/local/bin/gpio mode $pin out;");
		}
		#on fait 3 impulsions sur les pins activees
		my $i=0;
		my $nb=3;
		for($i=0 ; $i<$nb ; $i++){		
			#on met a 1 les pins
			foreach my $pin (@pinsAuto){
				system("/usr/local/bin/gpio write $pin 1;");
			}
			#on attend
			system("sleep 0.1");
			#on met a 0 les pins
			foreach my $pin (@pinsAuto){
				system("/usr/local/bin/gpio write $pin 0;");
			}
			#on attend
			system("sleep 0.1");
		}
		

	} else {
	#si le mode fete est actif et que l'on aurait du monter les volets
	#on ne monte pas les volets mais on desactive le mode fete
		$cfg->newval("ModeFete","modeFete","off");
		$cfg->WriteConfig("/home/bengo/Outils/automVr/config.ini");
	}
}

sub descenteAutoVolets {

	#on recupere les zones actives
	my @pinsAuto = ();
	if($zoneChambreRdcDescenteAuto eq "on") {
		push(@pinsAuto, @zoneChambreRdcPins);		
	}
	if($zoneChambresEtageDescenteAuto eq "on") {
		push(@pinsAuto, @zoneChambresEtagePins);		
	}
	#si le mode fete n'est pas actif	
	if($modeFete eq "off") {
		if($zonePieceDeVieDescenteAuto eq "on") {
			push(@pinsAuto, @zonePieceDeViePins);
		}
	}
	#on met en mode out les pins
	foreach my $pin (@pinsAuto){
		system("/usr/local/bin/gpio mode $pin out;");
	}
	#on fait 4 impulsions sur les pins activees
	my $i=0;
	my $nb=4;
	for($i=0 ; $i<$nb ; $i++){		
		#on met a 1 les pins
		foreach my $pin (@pinsAuto){
			system("/usr/local/bin/gpio write $pin 1;");
		}
		#on attend
		system("sleep 0.1");
		#on met a 0 les pins
		foreach my $pin (@pinsAuto){
			system("/usr/local/bin/gpio write $pin 0;");
		}
		#on attend
		system("sleep 0.1");
	}		
}


