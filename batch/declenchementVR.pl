#!/usr/bin/perl
use strict;
use warnings;
use Config::IniFiles;
use DateTime;
use DateTime::Event::Sunrise;

#on calcule l'heure de lever et de coucher du soleil
my $dt = DateTime->now(time_zone=>'local');

my $sunrise = DateTime::Event::Sunrise ->new (
                        longitude => '-4.632242',
                        latitude =>  '48.426059',
                   );
                   
my $both_times = $sunrise->sunrise_sunset_span( $dt );
                   
my $timeLeverJour = $both_times->start->datetime;; 
$timeLeverJour->set_second(0);                                
my $timeCoucherJour = $both_times->end->datetime;  
$timeCoucherJour->set_second(0);
  
# on ouvre le fichier de configuration 
my $cfg = Config::IniFiles->new( -file => "/home/bengo/Outils/automVr/config.ini");
my $modeFete = $cfg->val("ModeFete","modeFete");

#monter auto
my $zoneChambreRdcMonteeAuto = $cfg->val("ZonesMonteeAuto","zoneChambreRdc");
my $zoneChambresEtageMonteeAuto = $cfg->val("ZonesMonteeAuto","zoneChambresEtage");
my $zonePieceDeVieMonteeAuto = $cfg->val("ZonesMonteeAuto","zonePieceDeVie");

#descente auto
my $zoneChambreRdcDescenteAuto = $cfg->val("ZonesDescenteAuto","zoneChambreRdc");
my $zoneChambresEtageDescenteAuto = $cfg->val("ZonesDescenteAuto","zoneChambresEtage");
my $zonePieceDeVieDescenteAuto = $cfg->val("ZonesDescenteAuto","zonePieceDeVie");

#configuration des pins du port GPIO
my @zoneChambreRdcPins = split(/,/, $cfg->val("ZonesPins","zoneChambreRdc"));
my @zoneChambresEtagePins = split(/,/, $cfg->val("ZonesPins","zoneChambresEtage"));
my @zonePieceDeViePins = split(/,/, $cfg->val("ZonesPins","zonePieceDeVie"));

# test si on doit lever les volets
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

my $timeActuel = DateTime->new(
								year	=>$dt->year(),
								month	=>$dt->month(),
								day 	=>$dt->day(),
								hour	=>$dt->hour(),
								minute	=>$dt->minute(),
								);

# si le lever de soleil a lieu avant l'intervalle

if($timeLeverJour<$timeInflever) {
	print $timeLeverJour;
	print "\n";
	print $timeInflever;
	print "\n";
	if($timeActuel == $timeInflever) {
		print "Montee Auto : borne inferieure \n";
		monteeAutoVolets();	
	}
# si le lever de soleil a lieu dans l'intervalle 
} elsif($timeLeverJour>=$timeInflever && $timeLeverJour<=$timeSuplever){
	if($timeActuel == $timeLeverJour) {
		print "Montee Auto : heure soleil \n";
		monteeAutoVolets();	
	}
#sinon le lever de soleil a lieu apres l'intervalle
} else {
	if($timeActuel == $timeSuplever) {
		print "Montee Auto : borne superieure \n";
		monteeAutoVolets();	
	}	
}
	

# test si on doit baisser les volets
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

# si le coucher de soleil a lieu avant l'intervalle
if($timeCoucherJour<$timeInfCoucher) {
	if($timeActuel == $timeInfCoucher) {
		print "Descente Auto : borne inferieure \n";
		descenteAutoVolets();	
	}
# si le coucher de soleil a lieu dans l'intervalle
} elsif($timeCoucherJour>=$timeInfCoucher && $timeCoucherJour<=$timeSupCoucher){
	if($timeActuel == $timeCoucherJour) {
		print "Descente Auto : heure soleil \n";
		descenteAutoVolets();
	} 
# sinon le coucher de soleil a lieu apres l'intervalle
} else {
	if($timeActuel == $timeSupCoucher) {
		print "Descente Auto : borne superieure \n";
		descenteAutoVolets();	
	}
}

sub monteeAutoVolets {
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
