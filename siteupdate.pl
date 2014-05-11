#!/usr/bin/perl
#Site Update by Stephen Wetzel January 11th 2013
#checks for updates to websites. 
#downloads source of web page and extracts an user specified portion. 
#runs diff on that source every time it's ran to check for updates. 
#if an update is found it dumps it to stdout. 
#run with cron, and redirect stdout to email. 
#
#put sites in the /sites/ directory. 
#one text file per site. 
#line one is the url. 
#line two is the starting text (can be left blank to start at begining of file). 
#line three is the ending text (can be left blank). 
#following lines are ignored. 


use strict;
use warnings;

use WWW::Mechanize;
use Encode qw(encode_utf8);
use Text::Diff;

my $debug = 0; #set to 1 for lots of output
my $mech = WWW::Mechanize->new();
my $siteHtml; #stores actual html of site
my $startText; #everything on a site before this is ignored
my $endText; #everything on a site after this is ignored
my @fileArray; #stores contents of files
my $thisLine; #stores individual lines of a file
my $url; #url to check
my $diff=''; #diff of two versions of site
my $filename; #file name of the file that has the site info
my $htmlFile; #file name of html file
my $startDir = '/home/dale/Documents/Programming/Perl/siteupdate/sites'; #directory that has the files with site infos
my @fileList; #list of files in the startDir directory
my $ifile; #Input file
my $ofile; #output file

opendir(DIR, $startDir) or die "can't open: $startDir \n$!";
@fileList = readdir(DIR); #a listing of all files/directories including special directories (..)

foreach $filename (@fileList)
{#each of these files should represent a site to be checked
	next if ($filename =~ m/^\./); #skip the special directory
	next if ($filename !~ m/\.txt$/); #skip non text files
	if ($debug) {print "\n$filename";}
	$filename = $startDir . "/" . $filename; #append directory to filename
	$htmlFile = $filename;
	$htmlFile =~ s/\.txt$/\.html/; #change extension to html
	
	open $ifile, '<', $filename;
	@fileArray = <$ifile>; #load the contents of a config file for this site
	close $ifile;
	
	
	my $oldHtml = do 
	{
		local $/ = undef; #default record seperator, change to nothing, read entire file
		open $ifile, "<", $htmlFile	or 1 or open $ofile, ">", $htmlFile;
		<$ifile>; #dump contents to oldHtml
	};
	
	$url = $fileArray[0]; #the url is on the first line
	chomp($url);

	$startText = $fileArray[1]; #starting text is on 2nd line
	chomp($startText);
	$startText = quotemeta $startText; #ensure anything in startText won't interfere with regex

	$endText = $fileArray[2]; #ending text is on 3rd line
	chomp($endText);
	$endText = quotemeta $endText;

	if ($debug) {print "\nurl - $url\nstart - $startText\nend - $endText\ndiff- $diff";}
	
	$mech->add_header( Referer => undef );
	$mech->get($url); #grab the site data
	$siteHtml = $mech->res->decoded_content; #convert to html
	$siteHtml = encode_utf8($siteHtml); #get rid of unicode
	if ($startText) {$siteHtml =~ s/.*?$startText//s;} #strip everything prior to start text
	if ($endText) {$siteHtml =~ s/$endText.*//s}; #strip everything after the end text
	
	$diff = diff \$oldHtml, \$siteHtml; #find the diff
	
	if ($debug) {print "\ndiff: $diff";}
	if ($diff)
	{#there is a diff, site updated
		if ($debug) {print "\n\nUPDATE\n\n";}
		print "\nUPDATE:";
		print "\nurl - $url\nstart - $startText\nend - $endText\nDIFF:\n$diff";
		
		if ($debug) {print "\nOLD HTML:\n$oldHtml \nNEW HTML:\n$siteHtml";}
		open $ofile, '>', 'dump.html';
		print $ofile $siteHtml;
		close $ofile;
	}
	
	open $ofile, '>', $htmlFile;
	print $ofile $siteHtml;
	close $ofile;

	if ($debug) {print "\n";}
}

if ($debug) {print "\n\nDone!\n";}
