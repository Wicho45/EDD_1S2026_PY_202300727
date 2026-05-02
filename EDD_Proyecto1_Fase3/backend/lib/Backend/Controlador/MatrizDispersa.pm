package Backend::Controlador::MatrizDispersa;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../../lib";

use Backend::Modelo::NodoDato;
use Backend::Modelo::NodoCabecera;

sub new {
    my ($class) = @_;
    my $self = {
        lista_filas => undef,  
        lista_cols  => undef,  
        total_datos => 0,      
    };
    bless $self, $class;
    return $self;
}

sub insertar_o_sumar {
    my ($self, $proveedor_idx, $fabricante_idx, $cantidad) = @_;

    # DEBUG para consola
    print "DEBUG: Recibido en Matriz -> Prov: $proveedor_idx, Fab: $fabricante_idx, Cant: $cantidad\n";

    my $cab_fila = $self->_obtener_o_crear_cab_fila($proveedor_idx);
    my $cab_col  = $self->_obtener_o_crear_cab_col($fabricante_idx);

    my $existente = $self->obtener($proveedor_idx, $fabricante_idx);
    if (defined $existente) {
        my $nueva_cantidad = $existente->get_valor() + $cantidad;
        $existente->set_valor($nueva_cantidad);
        return;
    }

    my $nuevo = Modelo::NodoDato->new($proveedor_idx, $fabricante_idx, $cantidad);
    $self->_insertar_horizontal($cab_fila, $nuevo);
    $self->_insertar_vertical($cab_col, $nuevo);
    $self->{total_datos}++;
}

sub obtener {
    my ($self, $fila, $col) = @_;
    my $cab_fila = $self->buscar_cab_fila($fila);
    return undef unless defined $cab_fila;

    my $actual = $cab_fila->get_right();
    while (defined $actual) {
        return $actual if $actual->get_col() eq $col; # CAMBIO: eq
        $actual = $actual->get_right();
    }
    return undef;
}

sub buscar_cab_fila {
    my ($self, $fila_idx) = @_;
    my $actual = $self->{lista_filas};
    while (defined $actual) {
        return $actual if ($actual->get_label() eq $fila_idx); # CAMBIO: eq
        $actual = $actual->get_next();
    }
    return undef;
}

sub buscar_cab_col {
    my ($self, $col_idx) = @_;
    my $actual = $self->{lista_cols};
    while (defined $actual) {
        return $actual if ($actual->get_label() eq $col_idx); # CAMBIO: eq
        $actual = $actual->get_next();
    }
    return undef;
}

sub _obtener_o_crear_cab_fila {
    my ($self, $id) = @_;
    my $cab = $self->buscar_cab_fila($id);
    return $cab if defined $cab;

    my $nueva = Modelo::NodoCabecera->new($id);
    # CAMBIO: gt para orden alfabético
    if (!defined $self->{lista_filas} || $self->{lista_filas}->get_label() gt $id) {
        $nueva->set_next($self->{lista_filas});
        $self->{lista_filas} = $nueva;
    } else {
        my $act = $self->{lista_filas};
        # CAMBIO: lt para orden alfabético
        while (defined $act->get_next() && $act->get_next()->get_label() lt $id) {
            $act = $act->get_next();
        }
        $nueva->set_next($act->get_next());
        $act->set_next($nueva);
    }
    return $nueva;
}

sub _obtener_o_crear_cab_col {
    my ($self, $id) = @_;
    my $cab = $self->buscar_cab_col($id);
    return $cab if defined $cab;

    my $nueva = Modelo::NodoCabecera->new($id);
    # CAMBIO: gt
    if (!defined $self->{lista_cols} || $self->{lista_cols}->get_label() gt $id) {
        $nueva->set_next($self->{lista_cols});
        $self->{lista_cols} = $nueva;
    } else {
        my $act = $self->{lista_cols};
        # CAMBIO: lt
        while (defined $act->get_next() && $act->get_next()->get_label() lt $id) {
            $act = $act->get_next();
        }
        $nueva->set_next($act->get_next());
        $act->set_next($nueva);
    }
    return $nueva;
}

sub _insertar_horizontal {
    my ($self, $cab, $nuevo) = @_;
    my $act = $cab->get_right();
    # CAMBIO: gt
    if (!defined $act || $act->get_col() gt $nuevo->get_col()) {
        $nuevo->set_right($act);
        $cab->set_right($nuevo);
    } else {
        # CAMBIO: lt
        while (defined $act->get_right() && $act->get_right()->get_col() lt $nuevo->get_col()) {
            $act = $act->get_right();
        }
        $nuevo->set_right($act->get_right());
        $act->set_right($nuevo);
    }
}

sub _insertar_vertical {
    my ($self, $cab, $nuevo) = @_;
    my $act = $cab->get_down();
    # CAMBIO: gt
    if (!defined $act || $act->get_fila() gt $nuevo->get_fila()) {
        $nuevo->set_down($act);
        $cab->set_down($nuevo);
    } else {
        # CAMBIO: lt
        while (defined $act->get_down() && $act->get_down()->get_fila() lt $nuevo->get_fila()) {
            $act = $act->get_down();
        }
        $nuevo->set_down($act->get_down());
        $act->set_down($nuevo);
    }
}

1;