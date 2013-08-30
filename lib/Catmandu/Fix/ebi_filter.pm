package Catmandu::Fix::ebi_filter;

use Catmandu::Sane;
use Moo;

sub fix {
	my ($self, $ebi) = @_;
	
  my $hash = $ebi->{resultList}->{result};
  my $data;
  foreach (qw(pmid pmcid hasReferences citedByCount
      hasDbCrossReferences dbCrossReferenceList hasTextMinedTerms 
      hasReferences inEPMC inPMC)) {
    $data->{$_} = $hash->{$_} if $hash->{$_};
  }

  $data->{citedByCount} = $data->{citedByCount} ||= 0;

  return $data;

}

1;

=head1 Catmandu:Fix:ebi_filter

    Catmandu::Fix::ebi_filter - extract basic fields form EBI

=head1 SYNOPSIS

  use Catmandu::Fix qw(ebi_filter);
  use Catmandu::Importer::EBI;
  
  my $importer = Catmandu::Importer::EBI->new(query => 'doi:...');
    
  my $fixer = Catmandu::Fix->new(fixes => ['ebi_filter()']);

  #gives you an iterable object $ebi with filtered fields
  my $ebi = $fixer->fix($importer);
  $ebi->each( sub {
    my $pub = shift;
    #...
  });


=cut