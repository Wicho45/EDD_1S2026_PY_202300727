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

