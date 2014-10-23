#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

# This file is part of Filter-gunzip.
#
# Filter-gunzip is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Filter-gunzip is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Filter-gunzip.  If not, see <http://www.gnu.org/licenses/>.

use 5.010;
use strict;
use warnings;

use FindBin;
use File::Spec;
my $thisdir = $FindBin::Bin;
my $topdir = File::Spec->catdir ($FindBin::Bin, File::Spec->updir);


{
  my $status = system
    'perl', '-e', '{use open IN=>":gzip";require shift}',
    "$thisdir/show-argv.pl.gz", 'first arg', 'second arg';
  # 'examples/hello.pl.gz';
  print "exit $status\n";
  exit 0;
}

{
  eval '
require Data::Dumper;
print Data::Dumper->new([\*DATA],["DATA"])->Dump;
#print scalar(<DATA>);
__'.'DATA__
hello
';
  exit 0;
}


# {
#   use open IN => ':gzip(autopop)';
#   print ${^OPEN},"\n";
#   #   use PerlIO::gzip;
#   require 'examples/hello.pl.gz';
#   exit 0;
# }

{
  my $fh = \*DATA;
  print "tell() ",tell($fh),"\n";
  print "tell() ",tell(\*DATA),"\n";

  print "DATA layers\n";
  foreach my $layer (PerlIO::get_layers($fh)) {
    print '  ',$layer//'undef',"\n";
  }
  {
    print "layers detailed\n";
    my @layers = PerlIO::get_layers($fh, details=>1);
    while (@layers) {
      my ($name, $args, $flags) = splice @layers, 0,3;
      printf "%s  %s  %#X\n", $name, $args//'[undef]', $flags;
    }
  }

  exit 0;
}

{
  require Fcntl;
  #  my $filename = File::Spec->catfile ($topdir, 'examples', 'hello.pl.gz');

#   my $filename = '/usr/share/doc/groff-base/examples/hdtbl/fonts_x.ps.gz';
#   open my $fh, '<:mmap', $filename or die;

  my $filename = '/usr/share/perl/5.10.1/unicore/UnicodeData.txt';
  open my $fh, '<:mmap', $filename or die;

  print "sysseek ",sysseek($fh,0,Fcntl::SEEK_CUR()),"\n";
  print "tell    ",tell($fh),"\n";

  print scalar <$fh>;

  print "sysseek ",sysseek($fh,0,Fcntl::SEEK_CUR()),"\n";
  print "tell    ",tell($fh),"\n";

  exit 0;
}

# BEGIN {
#   require Filter::gunzip;
#   require Devel::Refcount;
#   for (0..10) {
#     my $aref = Filter::gunzip::_rsfp_filters();
#     print Devel::Refcount::refcount($aref),"\n";
#   }
#   my $fh = Filter::gunzip::_rsfp();
#   print "layers\n";
#   foreach my $layer (PerlIO::get_layers($fh)) {
#     print '  ',$layer//'undef',"\n";
#   }
#   {
#     print "layers detailed\n";
#     my @layers = PerlIO::get_layers($fh, details=>1);
#     while (@layers) {
#       my ($name, $args, $flags) = splice @layers, 0,3;
#       printf "%s  %s  %#X\n", $name, $args//'[undef]', $flags;
#     }
#   }
#   exit 0;
# }

{
  require Filter::gunzip;
  use FindBin;

  my $topdir = File::Spec->catdir ($FindBin::Bin, File::Spec->updir);
  my $libdir = File::Spec->catdir ($topdir, 'lib');
  my $blibdir = File::Spec->catdir ($topdir, 'blib');
  my $filename = File::Spec->catfile ($topdir, 'examples', 'hello.pl.gz');
  my @command = ("perl",
                 "-I", $libdir,
                 "-Mblib=$blibdir",
                 "-MFilter::gunzip::Filter",
                 $filename);
  { local $,=' '; print @command,"\n"; }
  system @command;
}

exit 0;


__DATA__



# sub import {
#   my ($class) = @_;
#   my $self = $class->new;
#   # avoid Filter::Util::Call 1.37 re-blessing the object if subclassing
#   $class = ref $self;
#   filter_add ($self);
#   bless $self, $class;
# }
