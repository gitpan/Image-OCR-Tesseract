package Image::OCR::Tesseract;
use strict;
use Carp;
use Cwd;
use Exporter;
use vars qw(@EXPORT_OK @ISA $VERSION $DEBUG $WHICH_TESSERACT $WHICH_CONVERT %EXPORT_TAGS @TRASH);
@ISA = qw(Exporter);
@EXPORT_OK = qw(get_ocr _tesseract convert_8bpp_tif tesseract);
$VERSION = sprintf "%d.%02d", q$Revision: 1.21 $ =~ /(\d+)/g;
%EXPORT_TAGS = ( all => \@EXPORT_OK );


BEGIN {
   use File::Which 'which';
   $WHICH_TESSERACT = which('tesseract');
   $WHICH_CONVERT   = which('convert');

   $WHICH_TESSERACT or die("Is tesseract installed? Cannot find bin path to tesseract.");
   $WHICH_CONVERT or die("Is convert installed? Cannot find bin path to convert.");
}

END {
   scalar @TRASH or return;
   if ( $DEBUG ){
      print STDERR "Debug on, these are trash files:\n".join("\n",@TRASH) ;
   }
   else {
      unlink @TRASH;
   }
}

sub DEBUG : lvalue { $DEBUG }
sub debug { print STDERR 'DEBUG '.__PACKAGE__.", @_\n" if $DEBUG; 1 }

sub get_ocr {
	my ($abs_image,$abs_tmp_dir,$lang )= @_;
	-f $abs_image or croak("$abs_image is not a file on disk");

   if(defined $abs_tmp_dir){

      -d $abs_tmp_dir or die("tmp dir arg $abs_tmp_dir not a dir on disk.");

      $abs_image=~/([^\/]+)$/ or die('cant match filename');
      my $abs_copy = "$abs_tmp_dir/$1";

      # TODO, what if source and dest are same, i want it to die
      require File::Copy;
      File::Copy::copy($abs_image, $abs_copy) 
         or die("cant make copy of $abs_image to $abs_copy, $!");

      # change the image to get ocr from to be the copy
      $abs_image = $abs_copy;
      # since it's a copy. erase that on exit
      push @TRASH, $abs_image;      
   }

   my $tmp_tif = convert_8bpp_tif($abs_image);
   
   push @TRASH, $tmp_tif; # for later delete

   _tesseract($tmp_tif,$lang) || '';
}

sub convert_8bpp_tif {
   my ($abs_img,$abs_out) = (shift,shift);
   defined $abs_img or die('missing image arg');

   $abs_out ||= $abs_img.'.tmp.'.time().(int rand(9000)).'.tif';
   
   my @arg = ( $WHICH_CONVERT, $abs_img, '-compress','none','+matte', $abs_out );
   system(@arg) == 0 or die("convert $abs_img error.. $?");

   debug("made $abs_out 8bpp tiff.");
   $abs_out;
}


*tesseract = \&_tesseract;
sub _tesseract {
	my ($abs_image,$lang) = @_;
   defined $abs_image or croak('missing image pah arg');
   
   
   my $cmd = "$WHICH_TESSERACT '$abs_image' '$abs_image'"
      . ( defined $lang ? " -l $lang" : '' )
      . "  2>/dev/null";
   debug("_tesseract command: $cmd");
	system($cmd); # hard to check ==0 

	my $txt = "$abs_image.txt";
   unless( -f $txt ){      
		carp( __PACKAGE__.", tesseract did not output? nothing inside [$abs_image]? ('$txt' not file on disk)");
      return;
   }

	debug("text saved as '$abs_image.txt'");
   
   my $content = (_slurp($txt) || '');   
   debug("content length is ". length $content );

   push @TRASH, $txt;

   $content;
}

sub _slurp {
   my $abs = shift;
   open(FILE,'<', $abs) or die("can't open file for reading '$abs', $!");
   local $/;
   my $txt = <FILE>;
   close FILE;
   $txt;
}  

1;


__END__

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


