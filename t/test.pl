use File::Which 'which';

sub have_tesseract { 
   File::Which::which('tesseract') ? 1 : 0;
}

1;
