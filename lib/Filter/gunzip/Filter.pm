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

package Filter::gunzip::Filter;
use strict;
use warnings;
use Carp;
use Filter::Util::Call qw(filter_add filter_read filter_del);
use Compress::Raw::Zlib qw(Z_OK Z_STREAM_END);

use vars '$VERSION';
$VERSION = 2;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant _INPUT_BLOCK_SIZE => 4096;

sub import {
  my ($class) = @_;

  # Filter::Util::Call 1.37 filter_add() rudely re-blesses the object into the
  # callers package.  Doesn't affect plain use here, but a subclass would want
  # to fix it up again.
  #
  ### filter_add()
  filter_add ($class->new);
}

sub new {
  my $class = shift;
  ### gunzip new(): $class

  # LimitOutput might help avoid growing $_ to a huge size if a few input
  # bytes expand to a lot of output.
  #
  # Crib note: Must have parens on MAX_WBITS() because it's unprototyped
  # (generated by Compress::Raw::Zlib::AUTOLOAD()) and hence without them
  # the "+ WANT_GZIP_OR_ZLIB" is passed as a parameter instead of adding.
  #
  my ($inf, $zerr) = Compress::Raw::Zlib::Inflate->new
    (-ConsumeInput => 1,
     -LimitOutput  => 1,
     -WindowBits   => (Compress::Raw::Zlib::MAX_WBITS()
                       + Compress::Raw::Zlib::WANT_GZIP_OR_ZLIB()));
  $inf or croak __PACKAGE__," cannot create inflator: $zerr";

  return bless { inflator => $inf,
                 input    => '',
                 @_ }, $class;
}

sub filter {
  my ($self) = @_;
  ### gunzip filter(): $self

  if (! $self->{'inflator'}) {
    ### inflator got to EOF, remove self
    filter_del();
    if ($self->{'input_eof'}) {
      ### input_eof
      return 0;
    } else {
      $_ = delete $self->{'input'};
      ### remaining input: $_
      ### return: 1
      return 1;
    }
  }

  # get more input data, if haven't seen input eof and if don't already have
  # some data to use
  #
  if (! $self->{'input_eof'} && ! length ($self->{'input'})) {
    my $status = filter_read(_INPUT_BLOCK_SIZE);
    ### filter_read(): $status
    if ($status < 0) {
      return $status;
    }
    if ($status == 0) {
      $self->{'input_eof'} = 1;
    } else {
      $self->{'input'} = $_;
    }
  }

  my $input_len_before = length($self->{'input'});
  my $zerr = $self->{'inflator'}->inflate ($self->{'input'}, $_);
  ### zinflate: $zerr+0, "$zerr"
  ### output len: length($_)
  ### leaving input len: length($self->{'input'})

  if ($zerr == Z_STREAM_END) {
    # inflator at eof, return final output now, next call will consider
    # balance of $self->{'input'}
    delete $self->{'inflator'};
    ### return final inflate: $_
    ### return: 1
    return 1;
  }

  my $status;
  if ($zerr == Z_OK) {
    if (length($_) == 0) {
      if ($input_len_before == length($self->{'input'})) {
        # protect against infinite loop
        carp __PACKAGE__,
          ' oops, inflator produced nothing and consumed nothing';
        return -1;
      }
      if ($self->{'input_eof'}) {
        # EOF on the input side (and $self->{'input_eof'} is only set when
        # $self->{'input'} is empty) but the inflator is not at EOF and has
        # no further output at this point
        carp __PACKAGE__," incomplete input";
        return -1;
      }
    }
    # It's possible $_ output is empty at this point if the inflator took
    # some input but had nothing to output just yet.  This is unlikely, but
    # if it happens there'll be another call to us immediately, no need to
    # do anything special.
    #### return continuing: $_
    return 1;
  }

  # $zerr not Z_OK and not Z_STREAM_END
  carp __PACKAGE__," error: $zerr";
  return -1;
}

1;
__END__

The PerlIO layer is pushed underneath any C<:crlf> layer.  

As of version 1.37 it connects the child process directly to the source file
and so avoids PerlIO layers like CRLF.  It might be good or bad to skip
layers or other earlier source filters, but it does make it 8-bit clean.
What should a binary mode filter do in general?

Other unrelated formats like
Unix C<compress> are left for other modules.

Depends: perl (>= 5.005), libfilter-perl, libcompress-raw-zlib-perl | perl (>= 5.10), libwarnings-perl | perl-modules (>= 5.6), ${perl:Depends}, ${misc:Depends}, ${shlibs:Depends}
