use lib inc; #__assertexe__#
use Devel::AssertEXE qw(tesseract convert); #__assertexe__#
use Devel::AssertOS qw(Unix Linux);

use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'Image::OCR::Tesseract',
    VERSION_FROM      => 'lib/Image/OCR/Tesseract.pm', # finds $VERSION
    PREREQ_PM         => {
      
					 'File::Copy' => 0,
					 'File::Path' => 0,					 
					 'File::Which' => 0,
					 'Carp' => 0,
		          'Image::Magick' => 0,
                'File::Find::Rule' => 0,
					 'LEOCHARRE::CLI' => '1.19',
					 },
    EXE_FILES               => [qw(bin/ocr)],
);



