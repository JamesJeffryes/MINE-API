package Bio::KBase::mine_database::Client;

use JSON::RPC::Legacy::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};


# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

Bio::KBase::mine_database::Client

=head1 DESCRIPTION


=head1 mineDatabaseServices

=head2 SYNOPSIS

The MINE database is fundamentally composed of two different types of documents, which are represented by the Compound
and Reaction objects. Users can use text-matching queries to access these records directly or perform two types of more
advanced queries: Mass Adduct queries and pathway queries. Mass Adduct queries return a list of compounds that might
match the m/z of an unknown compound. Pathway queries return either the shortest path or all paths between two compounds
 in the database.


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => Bio::KBase::mine_database::Client::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }


    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 model_search

  $models = $obj->model_search($query)

=over 4

=item Parameter and return types

=begin html

<pre>
$query is a string
$models is a reference to a list where each element is a string

</pre>

=end html

=begin text

$query is a string
$models is a reference to a list where each element is a string


=end text

=item Description

Returns a list of metabolic models that match the entered string

=back

=cut

sub model_search
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function model_search (received $n, expecting 1)");
    }
    {
	my($query) = @args;

	my @_bad_arguments;
        (!ref($query)) or push(@_bad_arguments, "Invalid type for argument 1 \"query\" (value was \"$query\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to model_search:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'model_search');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "mineDatabaseServices.model_search",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'model_search',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method model_search",
					    status_line => $self->{client}->status_line,
					    method_name => 'model_search',
				       );
    }
}



=head2 quick_search

  $quick_search_results = $obj->quick_search($db, $query)

=over 4

=item Parameter and return types

=begin html

<pre>
$db is a string
$query is a string
$quick_search_results is a reference to a list where each element is a comp_stub
comp_stub is a reference to a hash where the following keys are defined:
	id has a value which is an object_id
	MINE_id has a value which is a string
	Names has a value which is a reference to a list where each element is a string
	Formula has a value which is a string
object_id is a string

</pre>

=end html

=begin text

$db is a string
$query is a string
$quick_search_results is a reference to a list where each element is a comp_stub
comp_stub is a reference to a hash where the following keys are defined:
	id has a value which is an object_id
	MINE_id has a value which is a string
	Names has a value which is a reference to a list where each element is a string
	Formula has a value which is a string
object_id is a string


=end text

=item Description

Creates quick_search_results, a list of comp_stubs which match the query string. Searches for matches to KEGG
Codes, Inchi Keys, Brenda IDs and Names.

=back

=cut

sub quick_search
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function quick_search (received $n, expecting 2)");
    }
    {
	my($db, $query) = @args;

	my @_bad_arguments;
        (!ref($db)) or push(@_bad_arguments, "Invalid type for argument 1 \"db\" (value was \"$db\")");
        (!ref($query)) or push(@_bad_arguments, "Invalid type for argument 2 \"query\" (value was \"$query\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to quick_search:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'quick_search');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "mineDatabaseServices.quick_search",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'quick_search',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method quick_search",
					    status_line => $self->{client}->status_line,
					    method_name => 'quick_search',
				       );
    }
}



=head2 similarity_search

  $similarity_search_results = $obj->similarity_search($db, $comp_structure, $min_tc, $fp_type, $limit, $parent_filter, $reaction_filter)

=over 4

=item Parameter and return types

=begin html

<pre>
$db is a string
$comp_structure is a string
$min_tc is a float
$fp_type is a string
$limit is an int
$parent_filter is a string
$reaction_filter is a string
$similarity_search_results is a reference to a list where each element is a comp_stub
comp_stub is a reference to a hash where the following keys are defined:
	id has a value which is an object_id
	MINE_id has a value which is a string
	Names has a value which is a reference to a list where each element is a string
	Formula has a value which is a string
object_id is a string

</pre>

=end html

=begin text

$db is a string
$comp_structure is a string
$min_tc is a float
$fp_type is a string
$limit is an int
$parent_filter is a string
$reaction_filter is a string
$similarity_search_results is a reference to a list where each element is a comp_stub
comp_stub is a reference to a hash where the following keys are defined:
	id has a value which is an object_id
	MINE_id has a value which is a string
	Names has a value which is a reference to a list where each element is a string
	Formula has a value which is a string
object_id is a string


=end text

=item Description

Creates similarity_search_results, a list of comp_stubs shorter than the limit whose Tannimoto coefficient to
the comp_structure (as SMILES or molfile) is greater that the user set threshold. Uses open babel FP2 or FP4
fingerprints to perform the Tannimoto calculation. Also accepts a metabolic model with which to filter acceptable
source compounds or reaction types.

=back

=cut

sub similarity_search
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 7)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function similarity_search (received $n, expecting 7)");
    }
    {
	my($db, $comp_structure, $min_tc, $fp_type, $limit, $parent_filter, $reaction_filter) = @args;

	my @_bad_arguments;
        (!ref($db)) or push(@_bad_arguments, "Invalid type for argument 1 \"db\" (value was \"$db\")");
        (!ref($comp_structure)) or push(@_bad_arguments, "Invalid type for argument 2 \"comp_structure\" (value was \"$comp_structure\")");
        (!ref($min_tc)) or push(@_bad_arguments, "Invalid type for argument 3 \"min_tc\" (value was \"$min_tc\")");
        (!ref($fp_type)) or push(@_bad_arguments, "Invalid type for argument 4 \"fp_type\" (value was \"$fp_type\")");
        (!ref($limit)) or push(@_bad_arguments, "Invalid type for argument 5 \"limit\" (value was \"$limit\")");
        (!ref($parent_filter)) or push(@_bad_arguments, "Invalid type for argument 6 \"parent_filter\" (value was \"$parent_filter\")");
        (!ref($reaction_filter)) or push(@_bad_arguments, "Invalid type for argument 7 \"reaction_filter\" (value was \"$reaction_filter\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to similarity_search:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'similarity_search');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "mineDatabaseServices.similarity_search",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'similarity_search',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method similarity_search",
					    status_line => $self->{client}->status_line,
					    method_name => 'similarity_search',
				       );
    }
}



=head2 structure_search

  $structure_search_results = $obj->structure_search($db, $input_format, $comp_structure, $parent_filter, $reaction_filter)

=over 4

=item Parameter and return types

=begin html

<pre>
$db is a string
$input_format is a string
$comp_structure is a string
$parent_filter is a string
$reaction_filter is a string
$structure_search_results is a reference to a list where each element is a comp_stub
comp_stub is a reference to a hash where the following keys are defined:
	id has a value which is an object_id
	MINE_id has a value which is a string
	Names has a value which is a reference to a list where each element is a string
	Formula has a value which is a string
object_id is a string

</pre>

=end html

=begin text

$db is a string
$input_format is a string
$comp_structure is a string
$parent_filter is a string
$reaction_filter is a string
$structure_search_results is a reference to a list where each element is a comp_stub
comp_stub is a reference to a hash where the following keys are defined:
	id has a value which is an object_id
	MINE_id has a value which is a string
	Names has a value which is a reference to a list where each element is a string
	Formula has a value which is a string
object_id is a string


=end text

=item Description

Creates structure_search_result, a list of comp_stubs in the specified database that matches the the supplied
comp_structure. The input_format may be any format recognised by OpenBabel (i.e. mol, smi, inchi). Also accepts
a metabolic model with which to filter acceptable source compounds or reaction types.

=back

=cut

sub structure_search
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 5)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function structure_search (received $n, expecting 5)");
    }
    {
	my($db, $input_format, $comp_structure, $parent_filter, $reaction_filter) = @args;

	my @_bad_arguments;
        (!ref($db)) or push(@_bad_arguments, "Invalid type for argument 1 \"db\" (value was \"$db\")");
        (!ref($input_format)) or push(@_bad_arguments, "Invalid type for argument 2 \"input_format\" (value was \"$input_format\")");
        (!ref($comp_structure)) or push(@_bad_arguments, "Invalid type for argument 3 \"comp_structure\" (value was \"$comp_structure\")");
        (!ref($parent_filter)) or push(@_bad_arguments, "Invalid type for argument 4 \"parent_filter\" (value was \"$parent_filter\")");
        (!ref($reaction_filter)) or push(@_bad_arguments, "Invalid type for argument 5 \"reaction_filter\" (value was \"$reaction_filter\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to structure_search:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'structure_search');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "mineDatabaseServices.structure_search",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'structure_search',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method structure_search",
					    status_line => $self->{client}->status_line,
					    method_name => 'structure_search',
				       );
    }
}



=head2 substructure_search

  $substructure_search_results = $obj->substructure_search($db, $substructure, $limit, $parent_filter, $reaction_filter)

=over 4

=item Parameter and return types

=begin html

<pre>
$db is a string
$substructure is a string
$limit is an int
$parent_filter is a string
$reaction_filter is a string
$substructure_search_results is a reference to a list where each element is a comp_stub
comp_stub is a reference to a hash where the following keys are defined:
	id has a value which is an object_id
	MINE_id has a value which is a string
	Names has a value which is a reference to a list where each element is a string
	Formula has a value which is a string
object_id is a string

</pre>

=end html

=begin text

$db is a string
$substructure is a string
$limit is an int
$parent_filter is a string
$reaction_filter is a string
$substructure_search_results is a reference to a list where each element is a comp_stub
comp_stub is a reference to a hash where the following keys are defined:
	id has a value which is an object_id
	MINE_id has a value which is a string
	Names has a value which is a reference to a list where each element is a string
	Formula has a value which is a string
object_id is a string


=end text

=item Description

Creates substructure_search_results, a list of comp_stubs under the limit who contain the specified substructure
(as SMILES or molfile) Also accepts a metabolic model with which to filter acceptable source compounds or reaction types.

=back

=cut

sub substructure_search
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 5)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function substructure_search (received $n, expecting 5)");
    }
    {
	my($db, $substructure, $limit, $parent_filter, $reaction_filter) = @args;

	my @_bad_arguments;
        (!ref($db)) or push(@_bad_arguments, "Invalid type for argument 1 \"db\" (value was \"$db\")");
        (!ref($substructure)) or push(@_bad_arguments, "Invalid type for argument 2 \"substructure\" (value was \"$substructure\")");
        (!ref($limit)) or push(@_bad_arguments, "Invalid type for argument 3 \"limit\" (value was \"$limit\")");
        (!ref($parent_filter)) or push(@_bad_arguments, "Invalid type for argument 4 \"parent_filter\" (value was \"$parent_filter\")");
        (!ref($reaction_filter)) or push(@_bad_arguments, "Invalid type for argument 5 \"reaction_filter\" (value was \"$reaction_filter\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to substructure_search:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'substructure_search');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "mineDatabaseServices.substructure_search",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'substructure_search',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method substructure_search",
					    status_line => $self->{client}->status_line,
					    method_name => 'substructure_search',
				       );
    }
}



=head2 database_query

  $database_query_results = $obj->database_query($db, $mongo_query, $parent_filter, $reaction_filter)

=over 4

=item Parameter and return types

=begin html

<pre>
$db is a string
$mongo_query is a string
$parent_filter is a string
$reaction_filter is a string
$database_query_results is a reference to a list where each element is a comp_stub
comp_stub is a reference to a hash where the following keys are defined:
	id has a value which is an object_id
	MINE_id has a value which is a string
	Names has a value which is a reference to a list where each element is a string
	Formula has a value which is a string
object_id is a string

</pre>

=end html

=begin text

$db is a string
$mongo_query is a string
$parent_filter is a string
$reaction_filter is a string
$database_query_results is a reference to a list where each element is a comp_stub
comp_stub is a reference to a hash where the following keys are defined:
	id has a value which is an object_id
	MINE_id has a value which is a string
	Names has a value which is a reference to a list where each element is a string
	Formula has a value which is a string
object_id is a string


=end text

=item Description

A general function which uses mongo's find to create database_query_results, a list of object_ids which match
the specified json query
Input parameters for the "database_query" function:
string db - the database against which the query will be performed
mongo_query query - A valid mongo query as a string
string parent_filter - require all results originate from compounds in this specified metabolic model
string reaction_filter - require all results originate from operators which map to reactions in this specified metabolic model

=back

=cut

sub database_query
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 4)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function database_query (received $n, expecting 4)");
    }
    {
	my($db, $mongo_query, $parent_filter, $reaction_filter) = @args;

	my @_bad_arguments;
        (!ref($db)) or push(@_bad_arguments, "Invalid type for argument 1 \"db\" (value was \"$db\")");
        (!ref($mongo_query)) or push(@_bad_arguments, "Invalid type for argument 2 \"mongo_query\" (value was \"$mongo_query\")");
        (!ref($parent_filter)) or push(@_bad_arguments, "Invalid type for argument 3 \"parent_filter\" (value was \"$parent_filter\")");
        (!ref($reaction_filter)) or push(@_bad_arguments, "Invalid type for argument 4 \"reaction_filter\" (value was \"$reaction_filter\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to database_query:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'database_query');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "mineDatabaseServices.database_query",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'database_query',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method database_query",
					    status_line => $self->{client}->status_line,
					    method_name => 'database_query',
				       );
    }
}



=head2 get_ids

  $ids = $obj->get_ids($db, $collection, $query)

=over 4

=item Parameter and return types

=begin html

<pre>
$db is a string
$collection is a string
$query is a string
$ids is a reference to a list where each element is an object_id
object_id is a string

</pre>

=end html

=begin text

$db is a string
$collection is a string
$query is a string
$ids is a reference to a list where each element is an object_id
object_id is a string


=end text

=item Description

Return a list of object_ids in a specified collection in a specified db
Input parameters for the "get_ids" function:
string db - the database from which to retrieve ids
string collection - the collection from which to retrieve ids
        mongo_query query - A valid mongo query as a string

=back

=cut

sub get_ids
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_ids (received $n, expecting 3)");
    }
    {
	my($db, $collection, $query) = @args;

	my @_bad_arguments;
        (!ref($db)) or push(@_bad_arguments, "Invalid type for argument 1 \"db\" (value was \"$db\")");
        (!ref($collection)) or push(@_bad_arguments, "Invalid type for argument 2 \"collection\" (value was \"$collection\")");
        (!ref($query)) or push(@_bad_arguments, "Invalid type for argument 3 \"query\" (value was \"$query\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "mineDatabaseServices.get_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_ids',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_ids',
				       );
    }
}



=head2 get_comps

  $objects = $obj->get_comps($db, $ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$db is a string
$ids is a reference to a list where each element is an object_id
$objects is a reference to a list where each element is a CompoundObject
object_id is a string
CompoundObject is a reference to a hash where the following keys are defined:
	id has a value which is an object_id
	InChI_Key has a value which is a string
	Formula has a value which is a string
	Stringcode has a value which is a string
	Mass has a value which is a float
	Charge has a value which is an int
	DB_links has a value which is a reference to a list where each element is a string
	Reactant_in has a value which is a reference to a list where each element is an object_id
	Product_of has a value which is a reference to a list where each element is an object_id

</pre>

=end html

=begin text

$db is a string
$ids is a reference to a list where each element is an object_id
$objects is a reference to a list where each element is a CompoundObject
object_id is a string
CompoundObject is a reference to a hash where the following keys are defined:
	id has a value which is an object_id
	InChI_Key has a value which is a string
	Formula has a value which is a string
	Stringcode has a value which is a string
	Mass has a value which is a float
	Charge has a value which is an int
	DB_links has a value which is a reference to a list where each element is a string
	Reactant_in has a value which is a reference to a list where each element is an object_id
	Product_of has a value which is a reference to a list where each element is an object_id


=end text

=item Description

Return a list of CompoundObjects that match supplied object_ids in a specified db

=back

=cut

sub get_comps
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_comps (received $n, expecting 2)");
    }
    {
	my($db, $ids) = @args;

	my @_bad_arguments;
        (!ref($db)) or push(@_bad_arguments, "Invalid type for argument 1 \"db\" (value was \"$db\")");
        (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"ids\" (value was \"$ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_comps:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_comps');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "mineDatabaseServices.get_comps",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_comps',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_comps",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_comps',
				       );
    }
}



=head2 get_rxns

  $objects = $obj->get_rxns($db, $ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$db is a string
$ids is a reference to a list where each element is an object_id
$objects is a reference to a list where each element is a ReactionObject
object_id is a string
ReactionObject is a reference to a hash where the following keys are defined:
	id has a value which is an object_id
	Operators has a value which is a reference to a list where each element is a string
	Reactants has a value which is a reference to a list where each element is a rxn_comp
	Products has a value which is a reference to a list where each element is a rxn_comp
	Energy has a value which is a float
	Error has a value which is a float
rxn_comp is a reference to a list containing 2 items:
	0: (stoic) an int
	1: (id) an object_id

</pre>

=end html

=begin text

$db is a string
$ids is a reference to a list where each element is an object_id
$objects is a reference to a list where each element is a ReactionObject
object_id is a string
ReactionObject is a reference to a hash where the following keys are defined:
	id has a value which is an object_id
	Operators has a value which is a reference to a list where each element is a string
	Reactants has a value which is a reference to a list where each element is a rxn_comp
	Products has a value which is a reference to a list where each element is a rxn_comp
	Energy has a value which is a float
	Error has a value which is a float
rxn_comp is a reference to a list containing 2 items:
	0: (stoic) an int
	1: (id) an object_id


=end text

=item Description

Returns a list of ReactionObjects that match supplied object_ids in a specified db

=back

=cut

sub get_rxns
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_rxns (received $n, expecting 2)");
    }
    {
	my($db, $ids) = @args;

	my @_bad_arguments;
        (!ref($db)) or push(@_bad_arguments, "Invalid type for argument 1 \"db\" (value was \"$db\")");
        (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"ids\" (value was \"$ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_rxns:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_rxns');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "mineDatabaseServices.get_rxns",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_rxns',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_rxns",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_rxns',
				       );
    }
}



=head2 get_ops

  $objects = $obj->get_ops($db, $operator_names)

=over 4

=item Parameter and return types

=begin html

<pre>
$db is a string
$operator_names is a reference to a list where each element is a string
$objects is a reference to a list where each element is an OperatorObject
OperatorObject is a reference to a hash where the following keys are defined:
	Name has a value which is a string
	Reactions_predicted has a value which is an int
	Reaction_ids has a value which is a reference to a list where each element is an object_id
object_id is a string

</pre>

=end html

=begin text

$db is a string
$operator_names is a reference to a list where each element is a string
$objects is a reference to a list where each element is an OperatorObject
OperatorObject is a reference to a hash where the following keys are defined:
	Name has a value which is a string
	Reactions_predicted has a value which is an int
	Reaction_ids has a value which is a reference to a list where each element is an object_id
object_id is a string


=end text

=item Description

Returns a list of OperatorObjects that match supplied operator_names in a specified db

=back

=cut

sub get_ops
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_ops (received $n, expecting 2)");
    }
    {
	my($db, $operator_names) = @args;

	my @_bad_arguments;
        (!ref($db)) or push(@_bad_arguments, "Invalid type for argument 1 \"db\" (value was \"$db\")");
        (ref($operator_names) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"operator_names\" (value was \"$operator_names\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_ops:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_ops');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "mineDatabaseServices.get_ops",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_ops',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_ops",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_ops',
				       );
    }
}



=head2 get_operator

  $operator = $obj->get_operator($db, $operator_name)

=over 4

=item Parameter and return types

=begin html

<pre>
$db is a string
$operator_name is a string
$operator is an OperatorObject
OperatorObject is a reference to a hash where the following keys are defined:
	Name has a value which is a string
	Reactions_predicted has a value which is an int
	Reaction_ids has a value which is a reference to a list where each element is an object_id
object_id is a string

</pre>

=end html

=begin text

$db is a string
$operator_name is a string
$operator is an OperatorObject
OperatorObject is a reference to a hash where the following keys are defined:
	Name has a value which is a string
	Reactions_predicted has a value which is an int
	Reaction_ids has a value which is a reference to a list where each element is an object_id
object_id is a string


=end text

=item Description

Returns a OperatorObject with it's reaction IDs that matches supplied operator_name in a specified db

=back

=cut

sub get_operator
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_operator (received $n, expecting 2)");
    }
    {
	my($db, $operator_name) = @args;

	my @_bad_arguments;
        (!ref($db)) or push(@_bad_arguments, "Invalid type for argument 1 \"db\" (value was \"$db\")");
        (!ref($operator_name)) or push(@_bad_arguments, "Invalid type for argument 2 \"operator_name\" (value was \"$operator_name\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_operator:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_operator');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "mineDatabaseServices.get_operator",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_operator',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_operator",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_operator',
				       );
    }
}



=head2 get_adducts

  $adducts = $obj->get_adducts()

=over 4

=item Parameter and return types

=begin html

<pre>
$adducts is a reference to a list containing 2 items:
	0: a reference to a list where each element is a string
	1: a reference to a list where each element is a string

</pre>

=end html

=begin text

$adducts is a reference to a list containing 2 items:
	0: a reference to a list where each element is a string
	1: a reference to a list where each element is a string


=end text

=item Description

Returns a tuple of lists of positive and negative mass adducts names that may be used for querying the databases

=back

=cut

sub get_adducts
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 0)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_adducts (received $n, expecting 0)");
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "mineDatabaseServices.get_adducts",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_adducts',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_adducts",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_adducts',
				       );
    }
}



=head2 ms_adduct_search

  $ms_adduct_output = $obj->ms_adduct_search($text, $text_type, $ms_params)

=over 4

=item Parameter and return types

=begin html

<pre>
$text is a string
$text_type is a string
$ms_params is a mzParams
$ms_adduct_output is a reference to a list where each element is a ms_hit
mzParams is a reference to a hash where the following keys are defined:
	db has a value which is a string
	tolerance has a value which is a float
	adducts has a value which is a reference to a list where each element is a string
	models has a value which is a reference to a list where each element is a string
	logP has a value which is a reference to a list containing 2 items:
	0: a float
	1: a float

	kovats has a value which is a reference to a list containing 2 items:
	0: a float
	1: a float

	ppm has a value which is a bool
	charge has a value which is a bool
	halogen has a value which is a bool
bool is an int
ms_hit is a reference to a hash where the following keys are defined:
	peak_name has a value which is a string
	adduct has a value which is a string
	id has a value which is an object_id
	formula has a value which is a string
	MINE_id has a value which is an int
	name has a value which is a string
	SMILES has a value which is a string
	Inchikey has a value which is a string
	native_hit has a value which is a bool
	logP has a value which is a float
	minKovatsRI has a value which is a float
	maxKovatsRI has a value which is a float
	NP_likeness has a value which is a float
object_id is a string

</pre>

=end html

=begin text

$text is a string
$text_type is a string
$ms_params is a mzParams
$ms_adduct_output is a reference to a list where each element is a ms_hit
mzParams is a reference to a hash where the following keys are defined:
	db has a value which is a string
	tolerance has a value which is a float
	adducts has a value which is a reference to a list where each element is a string
	models has a value which is a reference to a list where each element is a string
	logP has a value which is a reference to a list containing 2 items:
	0: a float
	1: a float

	kovats has a value which is a reference to a list containing 2 items:
	0: a float
	1: a float

	ppm has a value which is a bool
	charge has a value which is a bool
	halogen has a value which is a bool
bool is an int
ms_hit is a reference to a hash where the following keys are defined:
	peak_name has a value which is a string
	adduct has a value which is a string
	id has a value which is an object_id
	formula has a value which is a string
	MINE_id has a value which is an int
	name has a value which is a string
	SMILES has a value which is a string
	Inchikey has a value which is a string
	native_hit has a value which is a bool
	logP has a value which is a float
	minKovatsRI has a value which is a float
	maxKovatsRI has a value which is a float
	NP_likeness has a value which is a float
object_id is a string


=end text

=item Description

New function replacing batch_ms_adduct_search

=back

=cut

sub ms_adduct_search
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function ms_adduct_search (received $n, expecting 3)");
    }
    {
	my($text, $text_type, $ms_params) = @args;

	my @_bad_arguments;
        (!ref($text)) or push(@_bad_arguments, "Invalid type for argument 1 \"text\" (value was \"$text\")");
        (!ref($text_type)) or push(@_bad_arguments, "Invalid type for argument 2 \"text_type\" (value was \"$text_type\")");
        (ref($ms_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 3 \"ms_params\" (value was \"$ms_params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to ms_adduct_search:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'ms_adduct_search');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "mineDatabaseServices.ms_adduct_search",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'ms_adduct_search',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method ms_adduct_search",
					    status_line => $self->{client}->status_line,
					    method_name => 'ms_adduct_search',
				       );
    }
}



=head2 ms2_search

  $ms_adduct_output = $obj->ms2_search($text, $text_type, $ms_params)

=over 4

=item Parameter and return types

=begin html

<pre>
$text is a string
$text_type is a string
$ms_params is a ms2Params
$ms_adduct_output is a reference to a list where each element is a ms_hit
ms2Params is a reference to a hash where the following keys are defined:
	db has a value which is a string
	tolerance has a value which is a float
	adducts has a value which is a reference to a list where each element is a string
	models has a value which is a reference to a list where each element is a string
	logP has a value which is a reference to a list containing 2 items:
	0: a float
	1: a float

	kovats has a value which is a reference to a list containing 2 items:
	0: a float
	1: a float

	scoring_function has a value which is a string
	energy_level has a value which is a float
	ppm has a value which is a bool
	charge has a value which is a bool
	halogen has a value which is a bool
bool is an int
ms_hit is a reference to a hash where the following keys are defined:
	peak_name has a value which is a string
	adduct has a value which is a string
	id has a value which is an object_id
	formula has a value which is a string
	MINE_id has a value which is an int
	name has a value which is a string
	SMILES has a value which is a string
	Inchikey has a value which is a string
	native_hit has a value which is a bool
	logP has a value which is a float
	minKovatsRI has a value which is a float
	maxKovatsRI has a value which is a float
	NP_likeness has a value which is a float
object_id is a string

</pre>

=end html

=begin text

$text is a string
$text_type is a string
$ms_params is a ms2Params
$ms_adduct_output is a reference to a list where each element is a ms_hit
ms2Params is a reference to a hash where the following keys are defined:
	db has a value which is a string
	tolerance has a value which is a float
	adducts has a value which is a reference to a list where each element is a string
	models has a value which is a reference to a list where each element is a string
	logP has a value which is a reference to a list containing 2 items:
	0: a float
	1: a float

	kovats has a value which is a reference to a list containing 2 items:
	0: a float
	1: a float

	scoring_function has a value which is a string
	energy_level has a value which is a float
	ppm has a value which is a bool
	charge has a value which is a bool
	halogen has a value which is a bool
bool is an int
ms_hit is a reference to a hash where the following keys are defined:
	peak_name has a value which is a string
	adduct has a value which is a string
	id has a value which is an object_id
	formula has a value which is a string
	MINE_id has a value which is an int
	name has a value which is a string
	SMILES has a value which is a string
	Inchikey has a value which is a string
	native_hit has a value which is a bool
	logP has a value which is a float
	minKovatsRI has a value which is a float
	maxKovatsRI has a value which is a float
	NP_likeness has a value which is a float
object_id is a string


=end text

=item Description

performs a ms adduct search but also scores hits using the supplied ms2 data

=back

=cut

sub ms2_search
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function ms2_search (received $n, expecting 3)");
    }
    {
	my($text, $text_type, $ms_params) = @args;

	my @_bad_arguments;
        (!ref($text)) or push(@_bad_arguments, "Invalid type for argument 1 \"text\" (value was \"$text\")");
        (!ref($text_type)) or push(@_bad_arguments, "Invalid type for argument 2 \"text_type\" (value was \"$text_type\")");
        (ref($ms_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 3 \"ms_params\" (value was \"$ms_params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to ms2_search:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'ms2_search');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "mineDatabaseServices.ms2_search",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'ms2_search',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method ms2_search",
					    status_line => $self->{client}->status_line,
					    method_name => 'ms2_search',
				       );
    }
}



=head2 pathway_search

  $pathway_query_results = $obj->pathway_search($db, $start_comp, $end_comp, $len_limit, $all_paths)

=over 4

=item Parameter and return types

=begin html

<pre>
$db is a string
$start_comp is an object_id
$end_comp is an object_id
$len_limit is an int
$all_paths is a bool
$pathway_query_results is a reference to a list where each element is a pathway
object_id is a string
bool is an int
pathway is a reference to a list where each element is an object_id

</pre>

=end html

=begin text

$db is a string
$start_comp is an object_id
$end_comp is an object_id
$len_limit is an int
$all_paths is a bool
$pathway_query_results is a reference to a list where each element is a pathway
object_id is a string
bool is an int
pathway is a reference to a list where each element is an object_id


=end text

=item Description

Creates pathway_query_results, a list of valid pathways (length one unless all_paths is true)

Input parameters for the "pathway_search" function:
string db - the database in which to search for pathways
object_id start_comp - the compound to begin the search from
        object_id end_comp - the compound that that a pathway will end with if successful
        int len_limit - the max number of intermediate reactions permitted in a path.
        bool all_paths - if true, the script returns all paths less that the limit not just the shortest path

=back

=cut

sub pathway_search
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 5)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function pathway_search (received $n, expecting 5)");
    }
    {
	my($db, $start_comp, $end_comp, $len_limit, $all_paths) = @args;

	my @_bad_arguments;
        (!ref($db)) or push(@_bad_arguments, "Invalid type for argument 1 \"db\" (value was \"$db\")");
        (!ref($start_comp)) or push(@_bad_arguments, "Invalid type for argument 2 \"start_comp\" (value was \"$start_comp\")");
        (!ref($end_comp)) or push(@_bad_arguments, "Invalid type for argument 3 \"end_comp\" (value was \"$end_comp\")");
        (!ref($len_limit)) or push(@_bad_arguments, "Invalid type for argument 4 \"len_limit\" (value was \"$len_limit\")");
        (!ref($all_paths)) or push(@_bad_arguments, "Invalid type for argument 5 \"all_paths\" (value was \"$all_paths\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to pathway_search:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'pathway_search');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "mineDatabaseServices.pathway_search",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'pathway_search',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method pathway_search",
					    status_line => $self->{client}->status_line,
					    method_name => 'pathway_search',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "mineDatabaseServices.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'pathway_search',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method pathway_search",
            status_line => $self->{client}->status_line,
            method_name => 'pathway_search',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for Bio::KBase::mine_database::Client\n";
    }
    if ($sMajor == 0) {
        warn "Bio::KBase::mine_database::Client version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 bool

=over 4



=item Description

indicates true or false values, false = 0, true =1


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 object_id

=over 4



=item Description

Unique ID of a compound or reaction derived from a hexdigest of the sha1 hash of a unique feature.
Starts with C if a compound, X if a cofactor and R if a reaction.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 comp_stub

=over 4



=item Description

A summery of a compound object which is returned from compound query

        object_id _id - unique ID of a compound
        string MINE_id - The a unique numerical id of a compound
        list<string> Names - common name for the compound
        string Formula - molecular formula of the compound


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is an object_id
MINE_id has a value which is a string
Names has a value which is a reference to a list where each element is a string
Formula has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is an object_id
MINE_id has a value which is a string
Names has a value which is a reference to a list where each element is a string
Formula has a value which is a string


=end text

=back



=head2 rxn_comp

=over 4



=item Description

A compound that is a component of a reaction as tuple of stoichiometric coefficient and _id


=item Definition

=begin html

<pre>
a reference to a list containing 2 items:
0: (stoic) an int
1: (id) an object_id

</pre>

=end html

=begin text

a reference to a list containing 2 items:
0: (stoic) an int
1: (id) an object_id


=end text

=back



=head2 pathway

=over 4



=item Description

A list of all the compounds and reactions in a pathway


=item Definition

=begin html

<pre>
a reference to a list where each element is an object_id
</pre>

=end html

=begin text

a reference to a list where each element is an object_id

=end text

=back



=head2 adduct_result

=over 4



=item Description

The result of a single adduct query on the database

        string adduct - the name of the mass adduct that returned the result
        string formula - the formula that was matched
        list<object_id> isomers - a list of the isomers of the formula present in the database


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
adduct has a value which is a string
formula has a value which is a string
isomers has a value which is a reference to a list where each element is a comp_stub

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
adduct has a value which is a string
formula has a value which is a string
isomers has a value which is a reference to a list where each element is a comp_stub


=end text

=back



=head2 peak

=over 4



=item Description

An annotated ms peak output by a batch mass adduct query

        string name - name of the peak
        float r_time - retention time
        float mz - mass to charge ratio
        bool charge - polarity of charge
        int num_forms - number of formula hits
        int num_hits - total number of compound matches
        bool native_hit - if true, one of the compounds suggested matches an native compound from the metabolic model
        list<adduct_result> adducts - the adducts that match a given peak


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
name has a value which is a string
num_forms has a value which is an int
num_hits has a value which is an int
native_hit has a value which is a bool
adducts has a value which is a reference to a list where each element is an adduct_result

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
name has a value which is a string
num_forms has a value which is an int
num_hits has a value which is an int
native_hit has a value which is a bool
adducts has a value which is a reference to a list where each element is an adduct_result


=end text

=back



=head2 ms_hit

=over 4



=item Description

A putative match for a metabolomics search
string peak_name
string adduct
object_id id
string formula
int MINE_id
string name
string SMILES
string Inchikey
bool native_hit - if true, hit is a member of the specified genomic reconstruction
int steps_from_source - The number of transformations the hit is from a source database compound
float logP - predicted partition coefficient
float minKovatsRI -
float maxKovatsRI - values of the predicted Kovats Retention Index
float NP_likeness - the natural product likeness score of the hit


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
peak_name has a value which is a string
adduct has a value which is a string
id has a value which is an object_id
formula has a value which is a string
MINE_id has a value which is an int
name has a value which is a string
SMILES has a value which is a string
Inchikey has a value which is a string
native_hit has a value which is a bool
logP has a value which is a float
minKovatsRI has a value which is a float
maxKovatsRI has a value which is a float
NP_likeness has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
peak_name has a value which is a string
adduct has a value which is a string
id has a value which is an object_id
formula has a value which is a string
MINE_id has a value which is an int
name has a value which is a string
SMILES has a value which is a string
Inchikey has a value which is a string
native_hit has a value which is a bool
logP has a value which is a float
minKovatsRI has a value which is a float
maxKovatsRI has a value which is a float
NP_likeness has a value which is a float


=end text

=back



=head2 CompoundObject

=over 4



=item Description

Data structures for a compound object

                Guaranteed:
                object_id id - A hexdigest of the sha1 hash of the openbabel canonical smile
                string InChI_Key - The first block of the InChI Key of a compound
                string Formula - The chemical formula of the compound
        string Stringcode - The canonical SMILE string generated by openbabel
                float Mass - The exact mass of the neutral form of a compound as calculated by openbabel
                int Charge - The total charge of the compound as calculated by ChemAxon

                Optionally:
        list<string> DB_links - links to the same compound in other databases
        list<object_id> Reactant_in - Reactions in which the compound is a reactant
        list<object_id> Product_of - Reactions in which the compound is a product


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is an object_id
InChI_Key has a value which is a string
Formula has a value which is a string
Stringcode has a value which is a string
Mass has a value which is a float
Charge has a value which is an int
DB_links has a value which is a reference to a list where each element is a string
Reactant_in has a value which is a reference to a list where each element is an object_id
Product_of has a value which is a reference to a list where each element is an object_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is an object_id
InChI_Key has a value which is a string
Formula has a value which is a string
Stringcode has a value which is a string
Mass has a value which is a float
Charge has a value which is an int
DB_links has a value which is a reference to a list where each element is a string
Reactant_in has a value which is a reference to a list where each element is an object_id
Product_of has a value which is a reference to a list where each element is an object_id


=end text

=back



=head2 ReactionObject

=over 4



=item Description

Data structures for a reaction object

                Guaranteed:
                object_id id - A hexdigest of the sha1 hash of the _ids of the reactants and products in sorted order
        list<string> Operators - The operator used to generate a particular reaction
        rxn_comps Reactants - Reactants of the reaction as tuples
        rxn_comps Products - Products of the reaction as tuples

        Optionally:
        float Energy - Delta G of reaction calculated by group contribution theory
        float Error - Estimated error of above energy


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is an object_id
Operators has a value which is a reference to a list where each element is a string
Reactants has a value which is a reference to a list where each element is a rxn_comp
Products has a value which is a reference to a list where each element is a rxn_comp
Energy has a value which is a float
Error has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is an object_id
Operators has a value which is a reference to a list where each element is a string
Reactants has a value which is a reference to a list where each element is a rxn_comp
Products has a value which is a reference to a list where each element is a rxn_comp
Energy has a value which is a float
Error has a value which is a float


=end text

=back



=head2 OperatorObject

=over 4



=item Description

Data structures for a operator object

                Guaranteed:
                string Name - Name of the operator
                int Reactions_predicted - The number of database reactions predicted by the operator
                list<object_id> Reaction_ids - A list of the _id hashes for the reaction

        Optionally:
        float Specificity - The fraction of predicted reactions which match known reactions
        float Avg_delta_G - The Average Delta G of all predicted reactions


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
Name has a value which is a string
Reactions_predicted has a value which is an int
Reaction_ids has a value which is a reference to a list where each element is an object_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
Name has a value which is a string
Reactions_predicted has a value which is an int
Reaction_ids has a value which is a reference to a list where each element is an object_id


=end text

=back



=head2 mzParams

=over 4



=item Description

Parameters for the ms adduct search function:

Input parameters for the "mass_adduct_query" function:
string db - the database in which to search for M/S matches
        float tolerance - the desired mass precision
        list<string> adduct_list - the adducts to consider in the query.
        list<string> models - the models in SEED that will be considered native metabolites(can be empty)
        tuple<float,float> logP - a tuple specifying the minimum and maximum values of logP values
        tuple<float,float> kovats - a tuple specifying the minimum and maximum values of Kovats RI
        bool ppm - if true, precision is supplied in parts per million. Else, precision is in Daltons
        bool charge - the polarity for molecules if not specified in file. 1 = +, 0 = -
        bool halogens - if false, compounds containing Cl, Br, and F will be excluded from results
        string parent_filter - require all results originate from compounds in this specified metabolic model
string reaction_filter - require all results originate from operators which map to reactions in this specified metabolic model


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
db has a value which is a string
tolerance has a value which is a float
adducts has a value which is a reference to a list where each element is a string
models has a value which is a reference to a list where each element is a string
logP has a value which is a reference to a list containing 2 items:
0: a float
1: a float

kovats has a value which is a reference to a list containing 2 items:
0: a float
1: a float

ppm has a value which is a bool
charge has a value which is a bool
halogen has a value which is a bool

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
db has a value which is a string
tolerance has a value which is a float
adducts has a value which is a reference to a list where each element is a string
models has a value which is a reference to a list where each element is a string
logP has a value which is a reference to a list containing 2 items:
0: a float
1: a float

kovats has a value which is a reference to a list containing 2 items:
0: a float
1: a float

ppm has a value which is a bool
charge has a value which is a bool
halogen has a value which is a bool


=end text

=back



=head2 ms2Params

=over 4



=item Description

Parameters for the ms2 adduct search function:

Input parameters for the "mass_adduct_query" function:
string db - the database in which to search for M/S matches
        float tolerance - the desired mass precision
        list<string> adduct_list - the adducts to consider in the query.
        list<string> models - the models in SEED that will be considered native metabolites(can be empty)
        tuple<float,float> logP - a tuple specifying the minimum and maximum values of logP values
        tuple<float,float> kovats - a tuple specifying the minimum and maximum values of Kovats RI
        string scoring_function - The name of the scoring function which will be used to score the spectra
        float energy_level - an integer from 0-2 specifying the fragmentation energy of the predicted spectra
        bool ppm - if true, precision is supplied in parts per million. Else, precision is in Daltons
        bool charge - the polarity for molecules if not specified in file. 1 = +, 0 = -
        bool halogens - if false, compounds containing Cl, Br, and F will be excluded from results
        string parent_filter - require all results originate from compounds in this specified metabolic model
string reaction_filter - require all results originate from operators which map to reactions in this specified metabolic model


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
db has a value which is a string
tolerance has a value which is a float
adducts has a value which is a reference to a list where each element is a string
models has a value which is a reference to a list where each element is a string
logP has a value which is a reference to a list containing 2 items:
0: a float
1: a float

kovats has a value which is a reference to a list containing 2 items:
0: a float
1: a float

scoring_function has a value which is a string
energy_level has a value which is a float
ppm has a value which is a bool
charge has a value which is a bool
halogen has a value which is a bool

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
db has a value which is a string
tolerance has a value which is a float
adducts has a value which is a reference to a list where each element is a string
models has a value which is a reference to a list where each element is a string
logP has a value which is a reference to a list containing 2 items:
0: a float
1: a float

kovats has a value which is a reference to a list containing 2 items:
0: a float
1: a float

scoring_function has a value which is a string
energy_level has a value which is a float
ppm has a value which is a bool
charge has a value which is a bool
halogen has a value which is a bool


=end text

=back



=cut

package Bio::KBase::mine_database::Client::RpcClient;
use base 'JSON::RPC::Legacy::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::Legacy::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::Legacy::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Legacy::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
