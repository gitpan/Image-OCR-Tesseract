package Image::OCR::Tesseract;
use strict;
use Carp;
use Cwd;
use File::Which;
require Exporter;
use vars qw(@EXPORT_OK @ISA $VERSION $DEBUG $WHICH_TESSERACT $WHICH_CONVERT %EXPORT_TAGS);
@ISA = qw(Exporter);
@EXPORT_OK = qw(get_ocr _tesseract convert_8bpp_tif tesseract);
$VERSION = sprintf "%d.%02d", q$Revision: 1.13 $ =~ /(\d+)/g;
%EXPORT_TAGS = ( all => \@EXPORT_OK );

$WHICH_TESSERACT = File::Which::which('tesseract') or die("Is tesseract installed?");
$WHICH_CONVERT   = File::Which::which('convert')   or die("Is convert installed?");

sub DEBUG : lvalue { $DEBUG }
sub debug {
   my $msg = shift;
   print STDERR 'DEBUG '.__PACKAGE__.", $msg\n" if DEBUG;
   return 1;
}

sub get_ocr {
	my ($abs_image,$abs_tmp )= @_;
	-f $abs_image or croak("$abs_image is not a file on disk");

   my $copied = 0;
   if(defined $abs_tmp){
      -d $abs_tmp or die("tmp dir arg $abs_tmp not a dir on disk.");
      $abs_image=~/([^\/]+)$/ or die('cant match filename');
      my $copyto = "$abs_tmp/$1";

      # TODO, what if source and dest are same, i want it to die
      require File::Copy;
      File::Copy::copy($abs_image, $copyto) or die("cant make copy of $abs_image to $copyto, $!");
      $abs_image = $copyto;
      $copied =1;
   }

   my $tmp_tif = convert_8bpp_tif($abs_image);

   my $content = _tesseract($tmp_tif);
   
   $DEBUG
      ? debug("$tmp_tif not unlinked because debug is on.")
      : unlink $tmp_tif;
   
   if($copied){
      debug("image was copied.. will unkink $abs_image");
      unlink $abs_image;
   }

   $content||='';
   return $content;
}

sub convert_8bpp_tif {
   my ($abs_img,$abs_out) = (shift,shift);
   defined $abs_img or die('missing image arg');

   $abs_out ||= $abs_img.'.tmp.'.time().(int rand(9000)).'.tif';
   
   my @arg = ( $WHICH_CONVERT, $abs_img, '-compress','none','+matte', $abs_out );
   system(@arg) == 0 or die("convert $abs_img error.. $?");

   debug("made $abs_out 8bpp tiff.");
   return $abs_out;
}


*tesseract = \&_tesseract;
sub _tesseract {
	my $abs_image = shift;
   defined $abs_image or croak('missing image pah arg');

	system("$WHICH_TESSERACT '$abs_image' '$abs_image' 2>/dev/null"); # hard to check ==0 

	my $txt = "$abs_image.txt";
   unless( -f $txt ){      
		warn("Tesseract did not output? nothing inside [$abs_image]? ('$txt' not file on disk)");
      return;
   }

	debug("text saved as '$abs_image.txt'");
   
   my $content = _slurp($txt);
   $content ||= '';
   debug("content length is ". length $content );

   unlink($txt) unless DEBUG;
   debug("did not unlink $txt, debug is on.");
   return $content;
}

sub _slurp {
   my $abs = shift;
   open(FILE,'<', $abs) or die("can't open file for reading '$abs', $!");
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

This is a wrapper for tesseract.
Tesseract expects a tiff file, get_ocr() will convert to a temporary tiff.
If your file is not a tiff file, that way you don't have to worry about 
your image format for ocr.

Tesseract spits out a text file- get_ocr() will erase that and return you the output.

=head1 SUBS

No subs are exported by default.

=head2 get_ocr()

Argument is abs path to image file. Can be most image formats.
Optional argument is abs path to temp dir.

If you don't have write access to the directory the image resides on, 
you should provide as argument a directory you do have write access to,
this would be the second argument.

Returns text content as read by tesseract.

Does not clean up after itself if DEBUG is on.

Warns if no output.

This takes care of converting to the right image format, etc.
The original image is unchanged.

=head2 tesseract()

Argument is abs path to tif file. 

Will return text output. 
If none inside or tesseract fails, returns empty string.
If tesseract fails, warns.

=head2 convert_8bpp_tif()

Argument is abs path to image file.
Optional argument is abs path to image out.
Returns abs path of image created. Uses 'convert', from ImageMagick.

=head1 TESSERACT NOTES

Tesseract is an open source ocr engine.
For an image to be read by tesseract properly, it must be an 8 bit per pixel tif format image file.
What this module does is to create a temporary file from your target image, which will be an 8 bit per pixel image, it then reads the output and returns it to you as a string.

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

An example using gocr as engine is L<Finance::MICR::GOCR::Check>. 

=head1 SEE ALSO

tesseract on google code.
gocr
convert ImageMagick.

ocr

=head1 CAVEATS

This module is for POSIX systems.
It is not intended to run on other "systems" and no support for such will be added
in the future.
Attempting to install on an unsupported OS will throw an exception.

=head1 DEBUG

Set the debug flag on:

	$Image::OCR::Tesseract::DEBUG = 1;

A temporary file is created, if DEBUG is on, the file is not deleted, the file path is printed to STDERR.

=head1 AUTHOR

Leo Charre leocharre at cpan dot org

=head1 COPYRIGHT

Copyright (c) 2008 Leo Charre. All rights reserved.

=head1 LICENSE

This package is free software; you can redistribute it and/or modify it under the same terms as Perl itself, i.e., under the terms of the "Artistic License" or the "GNU General Public License".

=head1 DISCLAIMER

This package is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the "GNU General Public License" for more details.

=cut
