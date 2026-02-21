package Modelo::Entrega;

use strict;
use warnings;

sub new {
    my ($class, $nit_proveedor, $fecha_entrega, $numero_factura, $codigo_medicamento, $cantidad_entregada) = @_;

    my $self = {
        nit_proveedor => $nit_proveedor,
        fecha_entrega => $fecha_entrega,
        numero_factura => $numero_factura,
        codigo_medicamento => $codigo_medicamento,
        cantidad_entregada => $cantidad_entregada
    };
}

#setters y getters

sub get_nit_proveedor {
    return $_[0]->{nit_proveedor};
}
sub set_nit_proveedor {
    my ($self, $nit_proveedor) = @_;
    $self->{nit_proveedor} = $nit_proveedor;
}

sub get_fecha_entrega {
    return $_[0]->{fecha_entrega};
}
sub set_fecha_entrega {
    my ($self, $fecha_entrega) = @_;
    $self->{fecha_entrega} = $fecha_entrega;
}

sub get_numero_factura {
    return $_[0]->{numero_factura};
}
sub set_numero_factura {
    my ($self, $numero_factura) = @_;
    $self->{numero_factura} = $numero_factura;
}

sub get_codigo_medicamento {
    return $_[0]->{codigo_medicamento};
}
sub set_codigo_medicamento {
    my ($self, $codigo_medicamento) = @_;
    $self->{codigo_medicamento} = $codigo_medicamento;
}

sub get_cantidad_entregada {
    return $_[0]->{cantidad_entregada};
}
sub set_cantidad_entregada {
    my ($self, $cantidad_entregada) = @_;
    $self->{cantidad_entregada} = $cantidad_entregada;
}

1;