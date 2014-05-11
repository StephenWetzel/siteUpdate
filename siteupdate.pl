#!/usr/bin/perl
#Site Update by Stephen Wetzel January 11th 2013
#downloads a site and finds the md5 hash of it
#if an old md5 hash exsists it compares them and alerts when they've changed
#it looks in a directory (sites) for any file, each represents a site to check
#each file has 4 lines: url; start text; end text; md5 hash
#anything before the start text or after end text is ignored, leave blank to check everything



use strict;
use warnings;

use WWW::Mechanize;
use Encode qw(encode_utf8);
use Text::Diff;

my $debug = 0; #set to 1 for lots of output
my $mech = WWW::Mechanize->new();
my $sitehtml; #stores actual html of site
my $starttext; #everything on a site before this is ignored
my $endtext; #everything on a site after this is ignored
my @filearray; #stores contents of files
my $fileline; #stores individual lines of a file
my $url; #url to check
my $diff=''; #diff of two versions of site
my $fname; #file name of the file that has the site info
my $htmlfile; #file name of html file
my $startdir = '/home/dale/Documents/Programming/Perl/siteupdate/sites'; #directory that has the files with site infos
my @filelist; #list of files in the startdir directory
my $ifile;
my $ofile;

opendir(DIR, $startdir) or die "can't open: $startdir \n$!";
@filelist = readdir(DIR); #a listing of all files/directories including special directories (..)



foreach $fname (@filelist)
{#each of these files should represent a site to be checked
	next if ($fname =~ m/^\./); #skip the special directory
	next if ($fname !~ m/\.txt$/); #only txt files
	if ($debug) {print "\n$fname";}
	$fname = $startdir . "/" . $fname; #append directory to filename
	$htmlfile = $fname;
	$htmlfile =~ s/\.txt$/\.html/;
	
	open $ifile, '<', $fname;
	@filearray = <$ifile>; #load the contents of a config file for this site
	close $ifile;
	
	
	
	
	my $oldhtml = do {
	local $/ = undef;
	open $ifile, "<", $htmlfile	or 1 or open $ofile, ">", $htmlfile;
	<$ifile>;
	};
	
	
	$url = $filearray[0]; #the url is on the first line
	chomp($url);

	$starttext = $filearray[1]; #starting text is on 2nd line
	chomp($starttext);
	$starttext = quotemeta $starttext;

	$endtext = $filearray[2]; #ending text is on 3rd line
	chomp($endtext);
	$endtext = quotemeta $endtext;

	if ($debug) {print "\nurl - $url\nstart - $starttext\nend - $endtext\ndiff- $diff";}
	
	$mech->add_header( Referer => undef );
	$mech->get($url); #grab the site data
	$sitehtml = $mech->res->decoded_content; #convert to html
	#if ($debug) {print $sitehtml;}
	$sitehtml = encode_utf8($sitehtml); #get rid of unicode
	if ($starttext) {$sitehtml =~ s/.*?$starttext//s;} #strip everything prior to start text
	if ($endtext) {$sitehtml =~ s/$endtext.*//s}; #strip everything after the end text
	
	
	$diff = diff \$oldhtml, \$sitehtml;
	
	
	
	if ($debug) {print "\ndiff: $diff";}
	if ($diff)
	{#site updated
		if ($debug) {print "\n\nUPDATE\n\n";}
		print "\nUPDATE:";
		print "\nurl - $url\nstart - $starttext\nend - $endtext\nDIFF:\n$diff";
		
		if ($debug) {print "\nOLD HTML:\n$oldhtml \nNEW HTML:\n$sitehtml";}
		open $ofile, '>', 'dump.html';
		print $ofile $sitehtml;
		close $ofile;
		#system("leafpad $fname&")
	}
	#if ($debug) {print "\n\n\n$sitehtml";}
	
	#open my $htmlfile, '>', 'html.html';
	#print $htmlfile $sitehtml;
	#close $htmlfile;
	
	open $ofile, '>', $htmlfile;
	print $ofile $sitehtml;
	close $ofile;

	if ($debug) {print "\n";}
}

if ($debug) {print "\n\nDone!\n";}
