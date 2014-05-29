#!/usr/bin/perl
use strict;
use warnings;
use DateTime;
use DateTime::Event::Sunrise;
use DateTime::Format::Strptime;

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


my $coucher = $parser->parse_datetime($both_times->end->datetime);
my $lever = $parser->parse_datetime($both_times->start->datetime);
my $duration = $lever->delta_ms($coucher);

print "Sunrise is: " , $lever, "\n";
print "Sunset is: " , $coucher, "\n";
print "Duree du jour: ", $duration->delta_minutes, "\n";


if($duration->delta_minutes>943){

print "test\n";
}
	
                   
