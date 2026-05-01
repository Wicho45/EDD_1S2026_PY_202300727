package Backend::Modelo::Usuario;

use strict;
use warnings;

##Constructor y getters/setters para la clase Usuario
sub new{
    my ($class, $username, $tipo, $numero_colegio, $password, $departamento, $especialidad) = @_;
    my $self = {
        username => $username,
        tipo => $tipo,
        numero_colegio => $numero_colegio,
        password => $password,
        departamento => $departamento,
        especialidad => $especialidad,
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

sub get_departamento {
    my ($self) = @_;
    return $self->{departamento};
}
sub set_departamento {
    my ($self, $departamento) = @_;
    $self->{departamento} = $departamento;
}

sub get_especialidad {
    my ($self) = @_;
    return $self->{especialidad};
}
sub set_especialidad {
    my ($self, $especialidad) = @_;
    $self->{especialidad} = $especialidad;
}

1;