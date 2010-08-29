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

use 5.005;
use strict;
use warnings;
use ExtUtils::MakeMaker;
use lib 'inc';
use MyMakeMakerExtras;

MyMakeMakerExtras::WriteMakefile
  (NAME         => 'Filter::gunzip',
   ABSTRACT     => 'Source filter uncompressing gzip files.',
   VERSION_FROM => 'lib/Filter/gunzip.pm',
   AUTHOR       => 'Kevin Ryde <user42@zip.com.au>',
   LICENSE      => 'gpl',
   SIGN         => 1,
   MIN_PERL_VERSION => '5.005',

   PREREQ_PM    => {
                    'warnings' => 0,
                    'Filter::Util::Call' => 0,
                    'Compress::Raw::Zlib' => 0,
                    'Test::More' => 0,
                    'PerlIO' => 0,
                    'PerlIO::gzip' => 0,
                   },

   META_MERGE
   => { resources
        => { homepage => 'http://user42.tuxfamily.org/filter-gunzip/index.html' },
        optional_features
        => { maximum_devel
             => { description => 'Stuff used variously for development.',
                  requires => { 'Compress::Zlib' => 0,
                                'Compress::Raw::Bzip2' => 0,
                                'Devel::Peek' => 0,
                                'Filter::Util::Call' => 0,
                                'BSD::Resource' => 0,
                                'Smart::Comments' => 0,
                                'Filter::exec' => 0,
                                'Filter::tee' => 0,
                                'lib::abs' => 0,
                              },
                },
           },
      },
  );
