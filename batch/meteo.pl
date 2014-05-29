#!/usr/bin/perl
use strict;
use warnings;
use Config::IniFiles;
use LWP::Simple;
use XML::Simple;
use DateTime;
use Encode;

# récupere la meteo grace a un appel a Weather Underground et enregistre les informations dans le fichier de config

# récupère le corps de la réponse
my $request = HTTP::Request->new(GET => "http://api.wunderground.com/api/1aeb6baa80e26423/geolookup/conditions/lang:FR/q/saint-renan.xml");
my $ua = new LWP::UserAgent();
my $response = $ua->request($request);

if ($response->is_error) {
	print STDERR $response->status_line, "\n";
	print STDERR status_message($response->status_line), "\n";
	print STDERR $response->error_as_HTML, "\n";
}
else { 
	my $meteoContent =  $response->decoded_content;

	my $meteoXml = XMLin($meteoContent);

	#on s'interesse a la temperature,  au vent, aux precipitations dans l'heure, a la pression, a la visibilite (en km) et aux nuages,
	my $observation = $meteoXml->{current_observation};

	# on ouvre le fichier de configuration 
	my $cfg = Config::IniFiles->new( -file => "/home/bengo/Outils/automVr/config.ini");
	
	$cfg->setval("Meteo","dateMeteo",DateTime->from_epoch(time_zone=>'local',epoch=>$observation->{observation_epoch}));
	$cfg->setval("Meteo","temperature",$observation->{temp_c});
	$cfg->setval("Meteo","vent",$observation->{wind_kph});
	if ($observation->{precip_1hr_metric}+0 ne $observation->{precip_1hr_metric}){
		$cfg->setval("Meteo","pluie",0);
	} else {
		$cfg->setval("Meteo","pluie",$observation->{precip_1hr_metric});
	}
	
	$cfg->setval("Meteo","pression",$observation->{pressure_mb});
	$cfg->setval("Meteo","visibilite",$observation->{visibility_km});
	$cfg->setval("Meteo","ciel",encode("utf8", $observation->{weather}));
	
	$cfg->WriteConfig("/home/bengo/Outils/automVr/config.ini");
}






