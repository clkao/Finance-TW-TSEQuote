#!/usr/bin/perl
use ExtUtils::MakeMaker;

WriteMakefile(
    AUTHOR		=> 'Chia-liang Kao (clkao@clkao.org)',
    ABSTRACT		=> 'Check stock quotes from Taiwan Securities Exchange with Perl',
    NAME		=> 'Finance::TW::TSEQuote',
    VERSION_FROM	=> 'lib/Finance/TW/TSEQuote.pm',
    DISTNAME		=> 'Finance-TW-TSEQuote',
    PREREQ_PM		=> {
	'LWP::Simple'	=> 0,
	'URI::Escape'	=> 0,
	($] < 5.008 ?
	 ('Encode::compat' => 0) : ())
    },

    dist		=> {
        COMPRESS	=> 'gzip -9',
        SUFFIX		=> '.gz',
    },
);

