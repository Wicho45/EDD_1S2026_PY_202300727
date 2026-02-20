package Modelo::Medicamento;

use strict;
use warnings;

sub new {
    my($class, $codigo_medicamento, $nombre_comercial, $principio_activo, $laboratorio_fabricante, $stock, $vencimiento, $precio, $nivel_reorden)= @_;
    my $self ={
        codigo_medicamento => $codigo_medicamento,
        nombre_comercial => $nombre_comercial,
        principio_activo => $principio_activo,
        laboratorio_fabricante => $laboratorio_fabricante,
        stock => $stock,
        vencimiento => $vencimiento,
        precio => $precio,
        nivel_reorden => $nivel_reorden
    };
    return bless $self, $class;
}

#setters y getters

sub get_codigo_medicamento{
    return $_[0]->{codigo_medicamento};
}
sub set_codigo_medicamento{
    my($self, $codigo_medicamento) = @_;
    $self->{codigo_medicamento} = $codigo_medicamento;
}

sub get_nombre_comercial{
    return $_[0]->{nombre_comercial};
}
sub set_nombre_comercial{
    my($self, $nombre_comercial) = @_;
    $self->{nombre_comercial} = $nombre_comercial;
}

sub get_principio_activo{
    return $_[0]->{principio_activo};
}
sub set_principio_activo{
    my($self, $principio_activo) = @_;
    $self->{principio_activo} = $principio_activo;
}

sub get_laboratorio_fabricante{
    return $_[0]->{laboratorio_fabricante};
}
sub set_laboratorio_fabricante{
    my($self, $laboratorio_fabricante) = @_;
    $self->{laboratorio_fabricante} = $laboratorio_fabricante;
}

sub get_stock{
    return $_[0]->{stock};
}
sub set_stock{
    my($self, $stock) = @_;
    $self->{stock} = $stock;
}

sub get_vencimiento{
    return $_[0]->{vencimiento};
}
sub set_vencimiento{
    my($self, $vencimiento) = @_;
    $self->{vencimiento} = $vencimiento;
}

sub get_precio{
    return $_[0]->{precio};
}
sub set_precio{
    my($self, $precio) = @_;
    $self->{precio} = $precio;
}

sub get_nivel_reorden{
    return $_[0]->{nivel_reorden};
}
sub set_nivel_reorden{
    my($self, $nivel_reorden) = @_;
    $self->{nivel_reorden} = $nivel_reorden;
}   

sub es_identico {
    my ($self, $otro) = @_;

    return (
        $self->{nombre}            eq $otro->{nombre}           &&
        $self->{principio_activo}  eq $otro->{principio_activo} &&
        $self->{laboratorio}       eq $otro->{laboratorio}      &&
        $self->{precio_unitario}   == $otro->{precio_unitario}  &&
        $self->{fecha_vencimiento} eq $otro->{fecha_vencimiento}
    );
}

1;