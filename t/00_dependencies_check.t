use Test::Simple 'no_plan';
require './t/test.pl';

ok(1,'testing for tesseract');

if ( have_tesseract() ){
   ok(1,'tesseract bin is found');
}
else {
   ok(1,'tesseract IS NOT INSTALLED');   
}



