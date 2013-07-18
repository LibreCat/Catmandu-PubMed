package Catmandu::Fix::ebi_enrich;

use Catmandu::Sane;
use Moo;

sub fix {
	my ($self, $ebi) = @_;
	
  my $data;
  foreach (qw(pmid pmcid hasReferences hasDbCrossReferences hasTextMinedTerms inEPMC inPMC)) {
    $data->{$_} = $ebi->{$_} if $ebi->{$_};
  }
  return $data;

}

1;

=head1 Catmandu:Fix:ebi_enrich

    Catmandu::Fix::ebi_enrich - extract basic fields form EBI

=head1 SYNOPSIS

    use Catmandu::Fix qw(ebi_enrich);
    
    my $data = { ... }; 
    my $fixer = Catmandu::Fix->new(fixes => ['ebi_enrich()']);
    $fixer->fix($data);

=cut