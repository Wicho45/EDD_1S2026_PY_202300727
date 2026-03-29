package Modelo::Proveedor;

use strict;
use warnings;

use Controlador::listaSimple;
use constant ListaSimple => 'Controlador::listaSimple';

sub new {
    my($class, $nit, $nombre_empresa, $contacto_principal, $telefono, $direccion)= @_;
    my $self = {
        nit => $nit,
        nombre_empresa => $nombre_empresa,
        contacto_principal => $contacto_principal,
        telefono => $telefono,
        direccion => $direccion, 
        historial => ListaSimple -> new()
    };
    return bless $self, $class;
}

#setters y getters
sub get_nit{
    return $_[0]->{nit};
}
sub set_nit{
    my($self, $nit) = @_;
    $self->{nit} = $nit;
}

sub get_nombre_empresa{
    return $_[0]->{nombre_empresa};
}
sub set_nombre_empresa{
    my($self, $nombre_empresa) = @_;
    $self->{nombre_empresa} = $nombre_empresa;
}

sub get_contacto_principal{
    return $_[0]->{contacto_principal};
}
sub set_contacto_principal{
    my($self, $contacto_principal) = @_;
    $self->{contacto_principal} = $contacto_principal;
}

sub get_telefono{
    return $_[0]->{telefono};
}
sub set_telefono{
    my($self, $telefono) = @_;
    $self->{telefono} = $telefono;
}

sub get_direccion{
    return $_[0]->{direccion};
}
sub set_direccion{
    my($self, $direccion) = @_;
    $self->{direccion} = $direccion;
}

sub get_historial {
    my ($self) = @_;
    return $self->{historial};
}

1;