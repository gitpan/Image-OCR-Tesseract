use lib inc; 
use Devel::AssertOS qw(Unix Linux);
use Devel::AssertEXE qw(tesseract convert);

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
					 'LEOCHARRE::CLI' => 0,
					 },
    EXE_FILES               => [qw(bin/ocr)],
);



