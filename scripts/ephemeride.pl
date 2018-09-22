#!/usr/bin/perl
use strict;
use warnings;
use Config::IniFiles;
use DateTime;
use DateTime::Event::Sunrise;
use DateTime::Format::Strptime;

my $fichierConf = "/home/bengo/Outils/automVr/config.ini";

# calcul l'heure de lever et de couche de soleil du jour
my $dt = DateTime->now(time_zone=>'local');

my $sunrise = DateTime::Event::Sunrise ->new (
                        longitude => '-4.632242',
                        latitude =>  '48.426059',
                   );

my $both_times = $sunrise->sunrise_sunset_span( $dt );

my $parser = DateTime::Format::Strptime->new(
    pattern     => '%Y-%m-%dT%H:%M:%S',
    time_zone   => 'local',
);
                   
my $timeLeverJour = $parser->parse_datetime($both_times->start);
$timeLeverJour->set_second(0);                                
my $timeCoucherJour = $parser->parse_datetime($both_times->end);  
$timeCoucherJour->set_second(0);

# on ouvre le fichier de configuration 
my $cfg = Config::IniFiles->new( -file => $fichierConf);
$cfg->setval("Ephemeride","leverSoleil",$timeLeverJour->strftime('%Y-%m-%dT%H:%M:%S'));
$cfg->setval("Ephemeride","coucherSoleil",$timeCoucherJour->strftime('%Y-%m-%dT%H:%M:%S'));
$cfg->WriteConfig($fichierConf);