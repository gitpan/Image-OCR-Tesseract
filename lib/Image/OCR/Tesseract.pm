package Image::OCR::Tesseract;
use strict;
use Carp;
use Cwd;
require Exporter;
use vars qw(@EXPORT_OK @ISA $VERSION $DEBUG);
@ISA = qw(Exporter);
@EXPORT_OK = qw(get_ocr _tesseract);
$VERSION = sprintf "%d.%02d", q$Revision: 1.10 $ =~ /(\d+)/g;

sub DEBUG : lvalue { $DEBUG }


sub _tesseractbin {
   unless( defined $Image::OCR::Tesseract::_tesseractbin ){
      require File::Which;
      $Image::OCR::Tesseract::_tesseractbin = File::Which::which('tesseract')
      or die("File::Which::which() cannot find path to tesseract bin, is tesseract installed?");
   }

   return $Image::OCR::Tesseract::_tesseractbin;
}

sub _convertbin {
   unless( defined $Image::OCR::Tesseract::_convertbin ){
      require File::Which;
      $Image::OCR::Tesseract::_convertbin = File::Which::which('convert')
      or die("File::Which::which() cannot find path to convert, is imagemagick installed?");
   }

   return $Image::OCR::Tesseract::_convertbin;
}


sub get_ocr {
	my ($abs_image,$abs_tmp )= @_;
	-f $abs_image or croak("$abs_image is not a file on disk");

   my $copied = 0;
   if(defined $abs_tmp){
      -d $abs_tmp or die("tmp dir arg $abs_tmp not a dir on disk.");
      $abs_image=~/([^\/]+)$/ or die('cant match filename');
      my $copyto = "$abs_tmp/$1";
      # require Cwd;
      # TODO, what if source and dest are same, i want it to die
      require File::Copy;
      File::Copy::copy($abs_image, $copyto) or die("cant make copy of $abs_image to $copyto, $!");
      $abs_image = $copyto;
      $copied =1;

   }


   my $tmp_tif = _8bpp_tif($abs_image);
   my $content = _tesseract($tmp_tif);
   
   if (DEBUG){
      print STDERR "8 bpp tif created: $tmp_tif,not deleted because debug is on.\n";
   }
   else {
      unlink $tmp_tif;
   }
   if($copied){
      print STDERR "image was copied.. will unkink $abs_image\n" if DEBUG;
      unlink $abs_image;
   }

   $content||='';
   return $content;
}

sub _8bpp_tif {
   my $img = shift;
   defined $img or die('missing image arg');

   my $tmp = $img.'.tmp.'.time().(int rand(9000)).'.tif';
   system(
      _convertbin(), $img, 
      qw(-compress none +matte),
      $tmp
   ) == 0 or die($?);
   return $tmp;
}

sub _tesseract {
	my $abs_image = shift;
   defined $abs_image or croak('missing image pah arg');
   my $tesseract =_tesseractbin();

	system("$tesseract $abs_image $abs_image 2>/dev/null");
	#	or warn("call to tesseract ocr failed, system [@args] : $?") and return;

      
	
	my $txt = "$abs_image.txt";
	print STDERR "text saved as '$abs_image.txt'\n" if DEBUG;
	my $content;
	if (-f $txt){
		#$content = File::Slurp::slurp($txt);
      $content = _slurp($txt);
      $content ||='';
		unlink($txt) unless DEBUG;
	}

	else {
		#$content = '';
		warn("tesseract did not output? nothing inside [$abs_image]?");		
      return;
	}
	return $content;
}

sub _slurp {
   my $abs = shift;
   open(FILE,'<', $abs) or die($!);
   local $/;
   my $txt = <FILE>;
   close FILE;
   return $txt;
}  

1;

#sub _force_imgtype {
#   my $img = shift;
#   my $type = shift;
#   my $delete_original = shift;
#   $delete_original ||=0;
#   
#
#   if($img=~/\.$type$/i){
#      return $img;
#   }
#
#   my $img_out= $img;
#   $img_out=~s/\.\w{1,5}$/\.$type/ or die("cant get file ext for $img");
#
#
#
#}


__END__

=pod

=head1 NAME

Image::OCR::Tesseract - read an image with tesseract and get output

=head1 SYNOPSIS

	use Image::OCR::Tesseract 'get_ocr';

	my $image = './hi.jpg';

	my $text = get_ocr($image);

=head1 DESCRIPTION

This is a simple wrapper for tesseract.
Tesseract expects a tiff file, get_ocr() will convert to a temporary tiff if 
your file is not a tiff file, that way you don't have to worry about your image format for ocr.

Tesseract spits out a text file- get_ocr() will erase that and return you the output.

=head1 get_ocr()

Argument is abs path to image file.
Optional argument is abs path to temp dir.
If you don't have write access to the directory the image resides on, 
you should provide as argument a directory you do have write access to.

Returns text content as read by tesseract.

Does not clean up after itself if DEBUG is on.

warns if no output

=head1 _tesseract()

Argument is abs path to tif file. Will return text output. 
If none inside or tesseract fails, returns empty string.
If tesseract fails, warns.


=head1 TESSERACT NOTES

tesseract is an open source ocr engine.
for an image to be read by tesseract properly, it must be an 8 bit per pixel tif format image file.
What this module does is to create a temporary file from your target image, which will be an 8 bit per pixel image.

=head2 INSTALLING TESSERACT

Included in this package is t/tesseract_install_helper.pl which will check for packages needed.

Installing tesseract can be tricky.
You will basically need gcc-c++ and automake installed on your system.

After you have automake and gcc-c++, you should be able to install.

=head3 SVN

You may be able to simply install the SVN version of Tesseract by using:

 svn checkout http://tesseract-ocr.googlecode.com/svn/trunk/ tesseract-ocr
 ./runautoconf
 mkdir build-directory
 cd build-directory
 ../configure
 make
 make install

for more see google project on ocr, they use tesseract

=head1 GOCR

Another great OCR engine is gocr, but it is not suited for the purpose of reading text from images.
gocr is great if you need to tweak what you are reading, and for other specialized purposes.

=head1 SEE ALSO

tesseract
gocr
convert
ocr


=head1 DEBUG

Set the debug flag on:

	$Image::OCR::Tesseract::DEBUG = 1;

A temporary file is created, if DEBUG is on, the file is not deleted, the file path is printed to STDERR.

=head1 AUTHOR

Leo Charre leocharre at cpan dot org

=head1 COPYRIGHT

Copyright (c) 2007 Leo Charre. All rights reserved.

=head1 LICENSE

This package is free software; you can redistribute it and/or modify it under the same terms as Perl itself, i.e., under the terms of the "Artistic License" or the "GNU General Public License".

=head1 DISCLAIMER

This package is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the "GNU General Public License" for more details.

=cut





