#!/usr/bin/env perl

use lib qw(../lib);
use Catmandu::Sane;
use Catmandu -load;
use Catmandu::Fix qw(ebi_filter ebi_dbLinks);
use Catmandu::Importer::EBI;
use Catmandu::Store::MongoDB;
use YAML;
Catmandu->load;
Catmandu->config;

# my $searchBag = Catmandu->store('search')->bag('publicationItem');
my $bag = Catmandu::Store::MongoDB->new(database_name => 'europmc');
my $dbLinks_fixer = Catmandu::Fix->new(fixes => ['ebi_dbLinks()']);
my $ebi_fixer = Catmandu::Fix->new(fixes => ['ebi_filter()']);

sub _get_data {
	my ($pmid, $mod, $db) = @_;
	
	my $results;
	my $page = 1;
	my $pages = 40; # this means a maximum of thousand items
	while($page <= $pages) {
		my $imp = Catmandu::Importer::EBI->new(
			query => $pmid, 
			module => $mod,
			db => $db,
			page => $page,
			);
		push @{$results}, $imp->first;
		$page++;
	 	next if $page > 2;
	 		#$results->{total} = $imp->first->{hitCount};
	 		use integer;
	 		$pages = ($imp->first->{hitCount}/25)+1;
	 }
	return $results;
}

# $searchBag->each( sub {
# 	my $pub = $_[0];
# 	if ($pub->{pubmedID}) {
# 		push @[$pubmed->{records}], { pub => $pub->{_id}, pmid => $pub->{pubmedID} };
# 	}
# });

my $pubmed = {
	records => [
	{pub => '1', pmid => '12368864'},
	{pub => '2', pmid => '19155533'},
	{pub => '3', pmid => '22246381'},
	]
};

foreach my $item ( @{ $pubmed->{records} } ) {
	
	my $pmid = $item->{pmid};
	my $data = { _id => $item->{pub}, pmid => $pmid};
	my $basic_imp = Catmandu::Importer::EBI->new(
		query => $pmid, 
		module => 'search',
		);

	my $basic_info = $ebi_fixer->fix($basic_imp->first);
	
	if ($basic_info->{hasReferences} eq 'Y') {
		my $references = _get_data($pmid, 'references');
		#print Dump $references,
		$data->{references} = $references;
	}
	
	if ($basic_info->{citedByCount} ne '0') {
		my $citations = _get_data($pmid, 'citations');
		#print Dump $citations,
		$data->{citations} = $citations;
	}

	if ($basic_info->{hasDbCrossReferences} eq 'Y') {
#			foreach my $db ( @{$_->{dbCrossReferenceList}} ) {
#				my $dbLinks = $dbLinks_fixer->fix( _get_data($pmid, 'databaseLinks', $db->{dbName}) );
#				$data->{databaseLinks} = $dbLinks;
#			}
	}
	print Dump $data;

}

=head1 NAME

	the new amazing enricher

=head2 PROCEDURE

	1. Search for doi
	2. search for pmid via doi
	3. enrich vie pmid

=cut