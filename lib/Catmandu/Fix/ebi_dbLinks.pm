package Catmandu::Fix::ebi_dbLinks;

use Catmandu::Sane;
use Moo;
use Switch;

my $DB_LINKS = {
	CHEMBL => 'https://www.ebi.ac.uk/chembl/target/inspect/',
	EMBL => 'http://www.ebi.ac.uk/ena/data/view/',
	UNIPROT => 'http://www.uniprot.org/uniprot/', # .html
	CHEBI => 'http://www.ebi.ac.uk/chebi/searchId.do?chebiId=',
	INTERPRO => 'http://www.ebi.ac.uk/interpro/IEntry?ac=',
	PDB => 'http://www.ebi.ac.uk/pdbe-srv/view/entry/', # /summary
	INTACT => 'http://www.ebi.ac.uk/intact/pages/details/details.xhtml?experimentAc=',
};

sub fix {
	my ($self, $data) = @_;

	my $references = $data->{dbCrossReferenceList}->{dbCrossReference};
    my $dataset;

    foreach my $key (keys %$references){
        my $dbCrossReferenceInfo = $references->{$key}->{dbCrossReferenceInfo};
        if(ref $dbCrossReferenceInfo ne 'ARRAY'){
        	$dbCrossReferenceInfo->{url} = $DB_LINKS->{uc $key} . $_->{info1};
        	(uc $key eq 'UNIPROT') && ($dbCrossReferenceInfo->{url} .= '.html');
        	(uc $key eq 'PDB') && ($dbCrossReferenceInfo->{url} .= '/summary');
        	push @{$dataset->{$key}}, $dbCrossReferenceInfo;
        } else {
        	foreach (@$dbCrossReferenceInfo){
        		$_->{$key} = $DB_LINKS->{uc $key} . $_->{info1};
        		(uc $key eq 'UNIPROT') && ($_->{$key} .= '.html');
        		(uc $key eq 'PDB') && ($_->{$key} .= '/summary');
        		push @{$dataset->{$key}}, $_;
        	}
        }

    }
    return $dataset;
}

1;