package Backend::Modelo::Equipo;

use strict;
use warnings;

sub new {
    my ($class, $codigo, $nombre, $fabricante, $precio_unitario, $cantidad, $fecha_ingreso, $nivel_minimo) = @_;
    my $self = {
        codigo => $codigo,
        nombre => $nombre,
        fabricante => $fabricante,
        precio_unitario => $precio_unitario,
        cantidad => $cantidad,
        fecha_ingreso => $fecha_ingreso,
        nivel_minimo => $nivel_minimo
    };
    return bless $self, $class;
}

## Setters y getters
sub get_codigo {
    return $_[0]->{codigo};
}
sub set_codigo {
    my ($self, $codigo) = @_;
    $self->{codigo} = $codigo;
}

sub get_nombre {
    return $_[0]->{nombre};
}
sub set_nombre {
    my ($self, $nombre) = @_;
    $self->{nombre} = $nombre;
}

sub get_fabricante {
    return $_[0]->{fabricante};
}
sub set_fabricante {
    my ($self, $fabricante) = @_;
    $self->{fabricante} = $fabricante;
}

sub get_precio_unitario {
    return $_[0]->{precio_unitario};
}
sub set_precio_unitario {
    my ($self, $precio_unitario) = @_;
    $self->{precio_unitario} = $precio_unitario;
}

sub get_cantidad {
    return $_[0]->{cantidad};
}
sub set_cantidad {
    my ($self, $cantidad) = @_;
    $self->{cantidad} = $cantidad;
}

sub get_fecha_ingreso {
    return $_[0]->{fecha_ingreso};
}
sub set_fecha_ingreso {
    my ($self, $fecha_ingreso) = @_;
    $self->{fecha_ingreso} = $fecha_ingreso;
}

sub get_nivel_minimo {
    return $_[0]->{nivel_minimo};
}
sub set_nivel_minimo {
    my ($self, $nivel_minimo) = @_;
    $self->{nivel_minimo} = $nivel_minimo;
}

1;