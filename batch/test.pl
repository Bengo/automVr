#!/usr/bin/perl
use strict;
use warnings;
use DateTime;
use DateTime::Event::Sunrise;


my $dt = DateTime->now(time_zone=>'local');

my $sunrise = DateTime::Event::Sunrise ->sunset (
                        longitude => '-4.632242',
                        latitude =>  '48.426059',
                   );
                   
                  
           
my $timeInflever = DateTime->new(	
								year	=>$dt->year(),
								month	=>$dt->month(),
								day 	=>$dt->day()
								hour	=>0
								);
print $timeInflever;							       
                   
