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

use strict;
use warnings;
use Test::More tests => 2;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

{
  require FindBin;
  require File::Spec;
  my $used_more_than_once = $FindBin::Bin;
  my $filename = File::Spec->catfile ($FindBin::Bin, 'test2.dat');

  use vars qw($test2);
  $test2 = 0;
  my $result = eval { no warnings;
                      require $filename };
  my $err = $@;
  is ($result, "test2 compressed end");
  is ($err, '');
}

exit 0;
