package Modelo::Reabastecimiento;

use strict;
use warnings;

sub new {
    my($class, $departamento_solicitante, $medicamento_requerido, $cantidad_solicitada, $fecha_solicitud, $prioridad, $justificacion) = @_;
    my $self ={
        departamento_solicitante => $departamento_solicitante,
        medicamento_requerido => $medicamento_requerido,
        cantidad_solicitada => $cantidad_solicitada,
        fecha_solicitud => $fecha_solicitud,
        estado => "pendiente",
        prioridad => $prioridad,
        justificacion => $justificacion
    };
    return bless $self, $class; 
}

#setters y getters

sub get_departamento_solicitante {
    return $_[0]->{departamento_solicitante};
}
sub set_departamento_solicitante {
    my($self, $departamento_solicitante) = @_;
    $self->{departamento_solicitante} = $departamento_solicitante;
}

sub get_medicamento_requerido {
    return $_[0]->{medicamento_requerido};
}
sub set_medicamento_requerido {
    my($self, $medicamento_requerido) = @_;
    $self->{medicamento_requerido} = $medicamento_requerido;
}

sub get_cantidad_solicitada {
    return $_[0]->{cantidad_solicitada};
}
sub set_cantidad_solicitada {
    my($self, $cantidad_solicitada) = @_;
    $self->{cantidad_solicitada} = $cantidad_solicitada;
}

sub get_fecha_solicitud {
    return $_[0]->{fecha_solicitud};
}
sub set_fecha_solicitud {
    my($self, $fecha_solicitud) = @_;
    $self->{fecha_solicitud} = $fecha_solicitud;
}

sub get_estado {
    return $_[0]->{estado};
}
sub set_estado {
    my($self, $estado) = @_;
    $self->{estado} = $estado;
}

sub get_prioridad {
    return $_[0]->{prioridad};
}
sub set_prioridad {
    my($self, $prioridad) = @_;
    $self->{prioridad} = $prioridad;
}

sub get_justificacion {
    return $_[0]->{justificacion};
}
sub set_justificacion {
    my($self, $justificacion) = @_;
    $self->{justificacion} = $justificacion;
}

1;