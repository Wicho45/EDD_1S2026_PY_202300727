package Backend::Modelo::Relacion;

use strict;
use warnings;

sub new{
    my ($class, $solicitante, $receptor, $estado) = @_;
    my $self = {
        solicitante => $solicitante,
        receptor => $receptor,
        estado => $estado,
    };
    return bless $self, $class;
}

sub get_solicitante {
    my ($self) = @_;
    return $self->{solicitante};
}
sub set_solicitante {
    my ($self, $solicitante) = @_;
    $self->{solicitante} = $solicitante;
}

sub get_receptor {
    my ($self) = @_;
    return $self->{receptor};
}
sub set_receptor {
    my ($self, $receptor) = @_;
    $self->{receptor} = $receptor;
}

sub get_estado {
    my ($self) = @_;
    return $self->{estado};
}
sub set_estado {
    my ($self, $estado) = @_;
    $self->{estado} = $estado;
}

1;