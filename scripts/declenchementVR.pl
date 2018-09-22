#!/usr/bin/perl
use strict;
use warnings;
use Config::IniFiles;
use DateTime;
use DateTime::Event::Sunrise;
use DateTime::Format::Strptime;


#Déclenchement automatique des volets en fonction des heures de lever/coucher su soleil
my $fichierConf = "/home/bengo/Outils/automVr/config.ini";

 my $parser = DateTime::Format::Strptime->new(
    pattern     => '%Y-%m-%dT%H:%M:%S',
    time_zone   => 'local',
);

# on ouvre le fichier de configuration 
my $cfg = Config::IniFiles->new( -file => $fichierConf);

my $modeFete = $cfg->val("ModeFete","modeFete");
my $positionIntermediaireAtteinte = $cfg->val("Intermediaire","positionAtteinte");

#montee auto
my $zoneChambreRdcMonteeAuto = $cfg->val("ZonesMonteeAuto","zoneChambreRdc");
my $zoneChambresEtageMonteeAuto = $cfg->val("ZonesMonteeAuto","zoneChambresEtage");
my $zonePieceDeVieMonteeAuto = $cfg->val("ZonesMonteeAuto","zonePieceDeVie");

#descente auto
my $zoneChambreRdcDescenteAuto = $cfg->val("ZonesDescenteAuto","zoneChambreRdc");
my $zoneChambresEtageDescenteAuto = $cfg->val("ZonesDescenteAuto","zoneChambresEtage");
my $zonePieceDeVieDescenteAuto = $cfg->val("ZonesDescenteAuto","zonePieceDeVie");

#position intermediaire auto
my $zoneChambreRdcIntermediaireAuto = $cfg->val("ZonesPositionIntermediaireAuto","zoneChambreRdc");
my $zoneChambresEtageIntermediaireAuto = $cfg->val("ZonesPositionIntermediaireAuto","zoneChambresEtage");
my $zonePieceDeVieIntermediaireAuto = $cfg->val("ZonesPositionIntermediaireAuto","zonePieceDeVie");

#date ephemeride
my $timeLeverJourString = $cfg->val("Ephemeride","leverSoleil");
my $timeLeverJour = $parser->parse_datetime($timeLeverJourString);
my $timeCoucherJourString = $cfg->val("Ephemeride","coucherSoleil");
my $timeCoucherJour = $parser->parse_datetime($timeCoucherJourString);

#date releve meteo
my $dateMeteoString = $cfg->val("Meteo","dateMeteo");
my $dateMeteo =$parser->parse_datetime($dateMeteoString);
my $temperature = $cfg->val("Meteo","temperature");
my $vent = $cfg->val("Meteo","vent");

#configuration des pins du port GPIO
my @zoneChambreRdcPins = split(/,/, $cfg->val("ZonesPins","zoneChambreRdc"));
my @zoneChambresEtagePins = split(/,/, $cfg->val("ZonesPins","zoneChambresEtage"));
my @zonePieceDeViePins = split(/,/, $cfg->val("ZonesPins","zonePieceDeVie"));

my @borneInfLever = split(/:/, $cfg->val("Scenario","borneInfLever"));
my $timeInflever = DateTime->new(	
								year	=>$dt->year(),
								month	=>$dt->month(),
								day 	=>$dt->day(),
								hour	=>$borneInfLever[0],
								minute	=>$borneInfLever[1]
								);


my @borneSupLever = split(/:/, $cfg->val("Scenario","borneSupLever"));
my $timeSuplever = DateTime->new(	
								year	=>$dt->year(),
								month	=>$dt->month(),
								day 	=>$dt->day(),
								hour	=>$borneSupLever[0],
								minute	=>$borneSupLever[1]
								);

my @borneInfCoucher = split(/:/, $cfg->val("Scenario","borneInfCoucher"));
my $timeInfCoucher = DateTime->new(	
								year	=>$dt->year(),
								month	=>$dt->month(),
								day 	=>$dt->day(),
								hour	=>$borneInfCoucher[0],
								minute	=>$borneInfCoucher[1]
								);

my @borneSupCoucher = split(/:/, $cfg->val("Scenario","borneSupCoucher"));
my $timeSupCoucher = DateTime->new(	
								year	=>$dt->year(),
								month	=>$dt->month(),
								day 	=>$dt->day(),
								hour	=>$borneSupCoucher[0],
								minute	=>$borneSupCoucher[1]
								);

my @borneInfIntermediaire = split(/:/, $cfg->val("Scenario","borneInfIntermediaire"));
my $timeInfIntermediaire = DateTime->new(	
								year	=>$dt->year(),
								month	=>$dt->month(),
								day 	=>$dt->day(),
								hour	=>$borneInfIntermediaire[0],
								minute	=>$borneInfIntermediaire[1]
								);

my @borneSupIntermediaire = split(/:/, $cfg->val("Scenario","borneSupIntermediaire"));
my $timeSupIntermediaire = DateTime->new(	
								year	=>$dt->year(),
								month	=>$dt->month(),
								day 	=>$dt->day(),
								hour	=>$borneSupIntermediaire[0],
								minute	=>$borneSupIntermediaire[1]
								);
								
my $timeActuel = DateTime->new(
								year	=>$dt->year(),
								month	=>$dt->month(),
								day 	=>$dt->day(),
								hour	=>$dt->hour(),
								minute	=>$dt->minute(),
								);


my @pinsAuto = ();

# test si on doit lever les volets
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
	#sinon le lever de soleil a lieu apres l'intervalle
	} else {
		if($timeActuel == $timeSuplever) {
			monteeAutoVolets();	
		}	
	}
	

# test si on doit baisser les volets
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
	# sinon le coucher de soleil a lieu apres l'intervalle
	} else {
		if($timeActuel == $timeSupCoucher) {
			descenteAutoVolets();	
		}
	}



# test si on doit mettre les volets en position intermediaire
	#si on est dans l'intervalle
	if($timeActuel>$timeInfIntermediaire && $timeActuel<$timeSupIntermediaire){
		#si on n'est pas deja dans la position intermediaire
		if($positionIntermediaireAtteinte eq "false"){
			#si le releve meteo date de moins de 30 minutes
			my $diff = $dt->delta_ms($dateMeteo);
			if($diff->minutes < 30 ){
				#si il fait plus de 19 deg et qu'il y a moins de 25 km/h de vent
				# TODO agir suivant couverture nuageuse
				if($temperature>=19 && $vent <= 25 ){
					positionIntermediaire();
				}	
			}		
		}	
	}

sub monteeAutoVolets {
	#si le mode fete n'est pas actif
	if($modeFete eq "off") {
		print "montee auto volet a $timeActuel \n";
		#on recupere les zones actives		
		if($zoneChambreRdcMonteeAuto eq "on") {
			push(@pinsAuto, @zoneChambreRdcPins);		
		}
		if($zoneChambresEtageMonteeAuto eq "on") {
			push(@pinsAuto, @zoneChambresEtagePins);		
		}
		if($zonePieceDeVieMonteeAuto eq "on") {
			push(@pinsAuto, @zonePieceDeViePins);
		}
		agirVolet(3);
		system("sleep 1.5");
	} else {
	#si le mode fete est actif et que l'on aurait du monter les volets
	#on ne monte pas les volets mais on desactive le mode fete
		$cfg->setval("ModeFete","modeFete","off");
		$cfg->WriteConfig($fichierConf);
	}
	
	$cfg->setval("Intermediaire","positionAtteinte","false");
	$cfg->WriteConfig($fichierConf);

}


sub descenteAutoVolets {
	print "descente auto volet a $timeActuel \n";

	#on recupere les zones actives
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

	#on fait 4 impulsions sur les pins activees
	agirVolet(4);
	system("sleep 1.5");
	$cfg->setval("Intermediaire","positionAtteinte","false");
	$cfg->WriteConfig($fichierConf);
}


sub positionIntermediaire {
	print "position intermediaire auto volet a $timeActuel \n";

	#on recupere les zones actives
	if($zoneChambreRdcIntermediaireAuto eq "on") {
		push(@pinsAuto, @zoneChambreRdcPins);		
	}
	if($zoneChambresEtageIntermediaireAuto eq "on") {
		push(@pinsAuto, @zoneChambresEtagePins);		
	}
	#si le mode fete n'est pas actif	
	if($modeFete eq "off") {
		if($zonePieceDeVieIntermediaireAuto eq "on") {
			push(@pinsAuto, @zonePieceDeViePins);
		}
	}

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
	$cfg->setval("Intermediaire","positionAtteinte","true");
	$cfg->WriteConfig($fichierConf);

}

#fonction permettant d'envoyer les commandes aux volets
sub agirVolet {

	#on met en mode out a 0 les pins
	foreach my $pin (@pinsAuto){
		system("gpio mode $pin out;");
		system("sleep 0.1");
		system("gpio write $pin 0;");
	}

	my $nbimpulsions = shift;
	my $i=0;

	system("sleep 0.1");
	#on met a 1 les pins
	foreach my $pin (@pinsAuto){
		for($i=0 ; $i<$nbimpulsions ; $i++){
			system("gpio write $pin 1;");
			#on attend
			system("sleep 0.1");
			#on met a 0 les pins
			system("gpio write $pin 0;");
			#on attend
			system("sleep 0.1");
		}
		#on attend
		system("sleep 0.1");
	}

	#on reinit en mode in a 0 les pins
	foreach my $pin (@pinsAuto){
		system("gpio write $pin 0;");
		system("sleep 0.1");
		system("gpio mode $pin in;");
	}
	return;
}

