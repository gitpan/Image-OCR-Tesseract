use Test::Simple 'no_plan';
use lib './lib';
require './t/test.pl';


unless( have_tesseract() ){
   ok(1,"$0, You do NOT HAVE tesseract intalled, please see README");
   exit;
}

use Image::OCR::Tesseract 'get_ocr';

my $DEBUG = 1;
$Image::OCR::Tesseract::DEBUG=$DEBUG;

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
   ok( $text = get_ocr($abs,$abs_tmp),"got text from $abs");
   print STDERR " = TEXT IS: \n $text\n\n" if $DEBUG;


   
}







