#!/usr/bin/env perl

use lib qw(../lib);
use Catmandu::Sane;
use Catmandu -load;
use Catmandu::Importer::EBI;
use Catmandu::Store::MongoDB;

Catmandu->load;
Catmandu->config;

my $searchBag = Catmandu->store('search')->bag('publicationItem');
my $bag = Catmandu::Store::MongoDB->new(database_name => 'europmc');
my $pubmed;


sub _get_references {
	my ($pmid, $mod) = @_;
	
	my $references;
	my $page = 1;
	my $pages = 40; # this means a maximum of thousand items
	while($page <= $pages) {
		my $ref_imp = Catmandu::Importer::EBI->new(
			query => $pmid, 
			module => $mod,
			page => $page;
			);
		push @results, $ref_imp->first->{citationList};
		$page++;
		next if $page > 2;
			use integer;
			$pages = ($ref_imp->first->{hitCount}/25)+1;
	}

	return @references;
}

$searchBag->each( sub {
	my $pub = $_[0];
	if ($pub->{pubmedID}) {
		push @[$pubmed->{records}], { pub => $pub->{_id}, pubmed => $pub->{pubmedID} };
	}
});

foreach my $item ( @{ $pubmend->{records} } ) {
	my $pmid = $item->{pubmedID};
	my $data;
	my $basic_imp = Catmandu::Importer::EBI->new(
		query => $pmid, 
		module => 'search',
		fix => 'ebi_filter()',
		);
	$data = { _id => $item->{pub}, pmid => $pmid};

	given ($basic_imp->first) {
		when ($_->{hasReferences} eq 'Y') {
			my $references = _get_data($pmid, 'reference');
			$data->{references} = $references;
		}
		when ($_->{citedByCount} ne '0') {
			my $citations = _get_data($pmid, 'citation');
			$data->{citations} = $citations;
		}
		when ($_->{hasDbCrossReferences} eq 'Y') {
			my $dbLinks = _get_data($pmid, 'databaseLinks');
			$data->{databaseLinks} = $dbLinks;
		}
		default {
			#say "Nothing found for $item->{pubmedID}" if $opt_v;
		}
	}

}
=head1 NAME

	the new amazing enricher

=head2 PROCEDURE

	1. Search for doi
	2. search for pmid via doi
	3. enrich vie pmid

=cut