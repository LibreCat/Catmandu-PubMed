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
  my $out = $xs->XMLin($in, 
    SuppressEmpty => '', 
    ForceArray => ['dbCrossReference', 'reference', 'citation'], 
    KeyAttr => 'dbName',
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

  Catmandu::Importer::EBI

=head2 API Documentation

  http://www.ebi.ac.uk/europepmc/

=cut