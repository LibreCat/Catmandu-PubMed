package Catmandu::Importer::EBI;

use Catmandu::Sane;
use Moo;
use Furl;
use XML::Simple qw(XMLin);

with 'Catmandu::Importer';

use constant BASE_URL => 'http://www.ebi.ac.uk/europepmc/webservices/rest';

has base => (is => 'ro', default => sub { return BASE_URL; });
has source => (is => 'ro', default => sub { return "MED"; });
has query => (is => 'ro', required => 1);
has module => (is => 'ro');
has db => (is => 'ro');
has page => (is => 'ro');

my %MAP = (references => 'reference',
  citations => 'citation',
  dbCrossReference => 'dbCrossReference');

# Returns the raw response object.
sub _request {
  my ($self, $url) = @_;

  my $furl = Furl->new(
    agent => 'Mozilla/5.0',
    timeout => 10
  );

  my $res = $furl->get($url);
  die $res->status_line unless $res->is_success;

  return $res;
}

# Returns a hash representation of the given XML.
sub _hashify {
  my ($self, $in) = @_;

  my $xs = XML::Simple->new();
  my $field = $MAP{$self->module};
  my $out = $xs->XMLin($in, 
    SuppressEmpty => '', 
    ForceArray => [$field],
    KeyAttr => [$field],
  );

  return $out;
}

# Returns the XML response body.
sub _call {
  my ($self) = @_;

  # construct the url
  my $url = $self->base;
  if ($self->module eq 'search') {
    $url .= '/search/query=' . $self->query;
  } else {
    $url .= '/'. $self->source .'/'. $self->query .'/'. $self->module;
    $url .= '/'. $self->db if $self->db;
    $url .= '/'. $self->page if $self->page;
  }

  # http get the url.
  my $res = $self->_request($url);

  # return the response body.
  return $res->{content};
}

sub _get_record {
  my ($self) = @_;
  
  # fetch the xml response and hashify it.
  my $xml = $self->_call;
  my $hash = $self->_hashify($xml);
    
  # return a reference to a hash.
  return $hash;
}

# Public Methods. --------------------------------------------------------------

sub generator {
  my ($self) = @_;

  return sub {
    $self->_get_record;
  };

#  my $return = 1;
  # return sub {
  # # hack to make iterator stop.
  # if ($return) {
  #   $return = 0;
  #   return $self->_get_record;
  # }
  # return undef;
  # };
}

1;

=head1 NAME

  Catmandu::Importer::EBI - Package that imports EBI data.

=head1 API Documentation

  This module use the REST service as described at http://www.ebi.ac.uk/europepmc/.

=head1 SYNOPSIS

  use Catmandu::Importer::EBI;

  my %attrs = (
    base => 'http://www.ebi.ac.uk/europepmc/webservices/rest',
    source => 'MED',
    query => 'malaria',
    module => 'search',
    db => 'EMBL',
    page => '2',
  );

  my $importer = Catmandu::Importer::PubMed->new(%attrs);

  my $n = $importer->each(sub {
    my $hashref = $_[0];
    # ...
  });

=head1 SEE ALSO

L<Catmandu::Iterable>, L<Catmandu::Importer::PubMed>

=cut