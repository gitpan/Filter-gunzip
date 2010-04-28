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

package Filter::gunzip;
use strict;
use warnings;
use Carp;
use DynaLoader;
use PerlIO;
use PerlIO::gzip;

use vars qw($VERSION @ISA);
$VERSION = 1;
@ISA = ('DynaLoader');

__PACKAGE__->bootstrap($VERSION);

# uncomment this to run the ### lines
#use Smart::Comments;

sub import {
  my ($class) = @_;

  ### _rsfp_filters(): scalar(@{_rsfp_filters()})
  if (! @{_rsfp_filters()}) {
    my $fh;
    ### _rsfp(): _rsfp()
    if (($fh = _rsfp())
        && eval { require PerlIO;
                  require PerlIO::gzip;
                  1 }) {
      ### fh: $fh
      ### tell: tell($fh)

      my @layers = PerlIO::get_layers($fh);
      ### layers: \@layers

      if ($layers[-1] eq 'crlf') {
        binmode ($fh, ':pop')
          or croak "Oops, cannot pop crlf layer: $!";
      }

      binmode ($fh, ':gzip')
        or croak "Cannot push gzip layer: $!";

      if ($layers[-1] eq 'crlf') {
        binmode ($fh, ':crlf')
          or croak "Oops, cannot re-push crlf layer: $!";
      }

      #   @layers = PerlIO::get_layers($fh);
      #   ### pushed gzip: \@layers
      return;
    }
  }

  require Filter::gunzip::Filter;
  Filter::gunzip::Filter->import;
}

1;
__END__

=for stopwords gunzip Filter-gunzip uncompresses gzipped self-uncompressing gunzipping CRLF gzip CRC checksum zlib unbuffered Ryde

=head1 NAME

Filter::gunzip - gunzip Perl source code for execution

=head1 SYNOPSIS

 perl -MFilter::gunzip foo.pl.gz

 use Filter::gunzip;
 ... # inline gzipped source code bytes

=head1 DESCRIPTION

This filter uncompresses gzipped Perl code for execution.  It's slightly a
proof of concept, but works well as far as it goes.  It can be used from the
command line to run a F<.pl.gz> file,

    perl -MFilter::gunzip foo.pl.gz

Or in a self-uncompressing executable beginning with a C<use> and gzip bytes
immediately following that line,

    #!/usr/bin/perl
    use Filter::gunzip;
    ... raw gzip bytes

The filter is implemented by pushing a C<PerlIO::gzip> layer for the usual
case that C<Filter::gunzip> is the first filter and PerlIO is available.
Otherwise a block-oriented source filter is used per L<perlfilter>.  In both
cases the compressed code can include further source filters in the usual
way.

=head2 DATA Handle

The C<__DATA__> token (L<perldata/Special Literals>) and C<DATA> handle can
be used in the compressed source some of the time.

For the PerlIO case the C<DATA> handle is simply the input, including the
C<:gzip> uncompressing layer, positioned just after the C<__DATA__> token.
This works well for data compressed along with the code, though
C<PerlIO::gzip> as of version 0.18 cannot dup or seek which means
C<SelfLoader> doesn't work.  (Both probably feasible, though seeking might
be slow.)

For the filter case C<DATA> doesn't really work properly.  Perl stops
reading from the source filters at the C<__DATA__> token, because that's
where the source ends.  But a block oriented filter like C<Filter::gunzip>
may read ahead in the input file, so the position the C<DATA> handle is left
is unpredictable, especially if there's a couple of block-oriented filters
stacked up.

=head2 Further Details

Perl source is normally read without CRLF translation (in Perl 5.6.1 and up
at least).  If C<Filter::gunzip> sees a C<:crlf> layer on the input it
pushes the C<:gzip> underneath that, since the CRLF is almost certainly
meant to apply to the text, not to the raw gzip bytes.  This should let it
work with a forced C<PERLIO=crlf> suggested by F<README.cygwin> (see
L<perlrun/"PERLIO">).

The gzip format has a CRC checksum at the end of the data.  This might catch
subtle corruption in the compressed bytes, though as of Perl 5.10 the parser
usually doesn't report a read error, and in any case the code is compiled
and C<BEGIN> blocks executed as uncompressing proceeds, so corruption is
likely to provoke an error before the CRC is reached.

Only the gzip format (RFC 1952) is supported.  Zlib format (RFC 1950)
differs only in the header, but C<PerlIO::gzip> (version 0.18) doesn't allow
it.  The actual C<gunzip> program can handle a couple of other formats, like
Unix F<.Z> C<compress>, but they're likely best left to other modules.

The bzip2 format could be handled by a very similar filter, if F<.pl.bz2>
files were used.  Its decompressor uses at least 2.5 Mbytes of memory
though, so if choosing a format there'd have to be a big disk saving before
it was worth that much at runtime.

=head1 OTHER WAYS TO DO IT

C<Filter::exec> and the C<zcat> program can the same thing, either from the
command line or self-expanding,

    perl -MFilter::exec=zcat foo.pl.gz

Because it's a block-oriented filter (as of version 1.37) a compressed
C<__DATA__> section within the script doesn't work.

C<PerlIO::gzip> can be pushed on the command line using the C<open> pragma
with a C<require>.  Since that pragma is lexical it doesn't affect other
later loads or opens.

    perl -e '{use open IN=>":gzip";require shift}' \
            foo.pl.gz arg1 arg2

It doesn't work to set a global C<PERLIO=':gzip(autopop)'> though, since the
default layers can only be Perl builtins (see L<perlrun/PERLIO>).

=head1 SEE ALSO

L<PerlIO::gzip>, L<PerlIO>, L<Filter::Util::Call>, L<Filter::exec>,
L<gzip(1)>, L<zcat(1)>

=head1 HOME PAGE

http://user42.tuxfamily.org/filter-gunzip/index.html

=head1 LICENSE

Filter-gunzip is Copyright 2010 Kevin Ryde

Filter-gunzip is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

Filter-gunzip is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Filter-gunzip.  If not, see <http://www.gnu.org/licenses/>.

=cut
