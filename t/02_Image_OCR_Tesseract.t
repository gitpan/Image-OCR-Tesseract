use Test::Simple 'no_plan';
use lib './lib';


BEGIN {
   ok 1, 'started';
   deps_cli() or exit;

   sub deps_cli {
      for my $bin ( qw(convert tesseract) ){      
         warn("# Testing for command dep: $bin ..");
         require File::Which;

         File::Which::which($bin) or warn("# Missing path to executable: $bin")
            and return 0;
         ok 1,"have path to executable $bin, good.. ";
      }
      1;
   }
}

use Image::OCR::Tesseract ':all';





my $DEBUG = 1;

$Image::OCR::Tesseract::DEBUG=1;

ok(1,"module loaded");



require File::Path;
my $abs_tmp = './t/tmp';
File::Path::rmtree($abs_tmp);
mkdir $abs_tmp;


my $abs_small = './t/img_small.jpg';
my $abs_med = './t/img_med.jpg';
my $abs_big = './t/img_big.jpg';

my @imgs =('./t/paragraph.jpg',$abs_small, $abs_med, $abs_big);

for my $abs (@imgs){
   my $text ;
   my $at;
   my $tx;
   ok( $at = convert_8bpp_tif($abs, './t/tmp/outtif.tif'), "8bpp $at");
   ok( $tx = tesseract($at));
   ok( length $tx);

   ok( $text = get_ocr($abs,$abs_tmp),"got text from $abs");
   print STDERR " = TEXT IS: \n $text\n\n" if $DEBUG;
   
}







