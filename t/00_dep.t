use Test::Simple 'no_plan';

use File::Which 'which';

for my $bin ( qw(convert tesseract) ){
   ok( which($bin), "found path to '$bin'");
}

