package Modelo::Usuario;

use strict;
use warnings;


sub new{
    my ($class, $username, $tipo, $numero_colegio, $password) = @_;
    my $self = {
        username => $username,
        tipo => $tipo,
        numero_colegio => $numero_colegio,
        password => $password
    };
    return bless $self, $class;
}

sub get_username {
    my ($self) = @_;
    return $self->{username};
}
sub set_username {
    my ($self, $username) = @_;
    $self->{username} = $username;
}

sub get_tipo {
    my ($self) = @_;
    return $self->{tipo};
}
sub set_tipo {
    my ($self, $tipo) = @_;
    $self->{tipo} = $tipo;
}

sub get_numero_colegio {
    my ($self) = @_;
    return $self->{numero_colegio};
}
sub set_numero_colegio {
    my ($self, $numero_colegio) = @_;
    $self->{numero_colegio} = $numero_colegio;
}

sub get_password {
    my ($self) = @_;
    return $self->{password};
}
sub set_password {
    my ($self, $password) = @_;
    $self->{password} = $password;
}

1;