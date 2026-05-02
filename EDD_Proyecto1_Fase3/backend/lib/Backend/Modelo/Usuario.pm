package Backend::Modelo::Usuario;

use strict;
use warnings;
use Backend::Controlador::listaSimple; 

sub new{
    my ($class, $username, $tipo, $numero_colegio, $password, $departamento, $especialidad) = @_;
    my $self = {
        username       => $username,
        tipo           => $tipo,
        numero_colegio => $numero_colegio,
        password       => $password,
        departamento   => $departamento,
        especialidad   => $especialidad,
        cola_solicitudes => Backend::Controlador::listaSimple->new(), 
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


sub get_cola_solicitudes {
    my ($self) = @_;
    return $self->{cola_solicitudes};
}

sub agregar_solicitud {
    my ($self, $obj_relacion) = @_;
    $self->{cola_solicitudes}->insertar($obj_relacion);
}

1;