package Finance::TW::TSEQuote;
$VERSION = '0.27';

use strict;
use LWP::Simple ();
eval { require 'Encode::compat' };
use Encode 'from_to';
use URI::Escape;

sub resolve {
    my $self = shift if ref($_[0]) eq __PACKAGE__;
    shift if $_[0] eq __PACKAGE__;
    my $name = shift;

    from_to($name, 'utf-8', 'big5');

    $name = uri_escape($name);

    my $content = LWP::Simple::get("http://mops.tse.com.tw/server-java/t05st49_1?step=1&kinds=sii&colorchg=1&type=01&nick_name=$name");

    my ($id, $fullname, $engname) = $content =~ m|<td>(\d+)&nbsp;</td><td>(.*?)&nbsp;</td><td>(.*?)&nbsp;</td></tr>|;

    die "can't resolve symbol: $name" unless $id;

    from_to($fullname, 'big5', 'utf-8');

    @{$self}{qw/id fullname engname/} = ($id, $fullname, $engname);

    return $id;

}

sub new {
    my ($class, $target) = @_;
    my $self = bless {}, $class;

    $self->resolve($target)
	unless $target =~ /^\d+$/;

    $self->{id} ||= $target;

    return $self;
}

no utf8;
no encoding;

sub get {
    my $self = shift;
    my $stockno = ref $self ? $self->{id} : shift;
    my $content = LWP::Simple::get("http://mis.tse.com.tw/data/$stockno.csv");
    from_to($content, 'big5', 'utf-8');

    my $result;
    $content =~ s/"//g;
    my @info = split /,/, $content;
    my $cmap = [undef, 'UpDown', 'time', 'UpPrice', 'DownPrice', 'OpenPrice',
		'HighPrice', 'LowPrice', 'MatchPrice', 'MatchQty', 'DQty'];
    $result->{$cmap->[$_]} = $info[$_] foreach (0..10);
    $result->{name} = $info[32];
    $self->{name} ||= $result->{name} if ref $self;

    if ($result->{MatchPrice} == $result->{UpPrice}) {
	$result->{UpDownMark} = '♁';
    }
    elsif ($result->{MatchPrice} == $result->{DownPrice}) {
	$result->{UpDownMark} = '?';
    }
    elsif ($result->{UpDown} > 0) {
	$result->{UpDownMark} = '＋';
    }
    elsif ($result->{UpDown} < 0) {
	$result->{UpDownMark} = '－';
    }

    $result->{Bid}{Buy}[$_]{$info[11+$_*2]} = $info[12+$_*2] foreach (0..4);
    $result->{Bid}{Sell}[$_]{$info[21+$_*2]} = $info[22+$_*2] foreach (0..4);

    $self->{quote} = $result if ref $self;

    return $result;
}


1;

=head1 NAME

Finance::TW::TSEQuote - Check stock quotes from Taiwan Security Exchange

=head1 SYNOPSIS

    use Finance::TW::TSEQuote;

    my $quote = Finance::TW::TSEQuote->new('2002');

    while (1) { print $quote->get->{MatchPrice}.$/; sleep 30 }

=head1 DESCRIPTION

This module provides interface to stock information available from
Taiwan Security Exchange. You could resolve company name to stock
symbol, as well as getting the real time quote.

=head1 CLASS METHODS

=over 4

=item new

    Create a stock quote object. Resolve the name to symbol
    if the argument is not a symbol.

=item resolve

    Resolve the company name to stock symbol.

=item get

    Get the real time stock information.
    Return a hash containing stock information. The keys are:

=over 4

=item Bid

    a hash of array of best 5 matching Sell and Buy bids

=item DQty

    current volume

=item MatchQty

    daily volume

=item MatchPrice

    current price

=item OpenPrice

    opening price

=item HighPrice

    daily high

=item LowPrice

    daily low

=back

=back

=head1 AUTHORS

Chia-liang Kao E<lt>clkao@clkao.orgE<gt>

=head1 COPYRIGHT

Copyright 2003 by Chia-liang Kao E<lt>clkao@clkao.orgE<gt>.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut

