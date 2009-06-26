use lib inc; #__assertexe__#
use Devel::AssertEXE qw(tesseract convert); #__assertexe__#
use Devel::AssertOS qw(Unix Linux);

use ExtUtils::MakeMaker;

WriteMakefile(
   NAME => 'Image::OCR::Tesseract',
   VERSION_FROM => 'lib/Image/OCR/Tesseract.pm',
   

   # gen /usr/bin/pmused by Fri Jun 26 10:10:31 EDT 2009 
   PREREQ_PM => {
      'Carp'                              => '1',
      'Cwd'                               => '3',
      'Exporter'                          => '5',
      'File::Copy'                        => '2.09',
      'File::Find::Rule'                  => '0.30',
      'File::Path'                        => '2.07',
      'File::Spec'                        => '3.29',
      'File::Which'                       => '0.05',
      'LEOCHARRE::CLI'                    => '1.19',
      'Test::Simple'                      => '0',
   },

   
   LICENSE => 'perl',
   
   
   
   EXE_FILES => [qw(bin/ocr)],
);


