package Controlador::MatrizDispersa;

use strict;
use warnings;

use Modelo::NodoDato;
use constant NodoDato => 'Modelo::NodoDato';

use Modelo::NodoCabecera;
use constant NodoCabecera => 'Modelo::NodoCabecera';

sub new {
    my ($class, $num_filas, $num_cols) = @_;

    my $self = {
        lista_filas => undef,  
        lista_cols  => undef,  
        num_filas   => $num_filas || 0,
        num_cols    => $num_cols  || 0,
        total_datos => 0,      
    };

    bless $self, $class;
    return $self;
}

sub buscar_cab_fila {
    my ($self, $fila_idx) = @_;
    my $actual = $self->{lista_filas};
    while (defined $actual) {
        return $actual if ($actual->get_label() == $fila_idx);
        last if ($actual->get_label() > $fila_idx);
        $actual = $actual->get_next();
    }
    return undef;
}

sub buscar_cab_col {
    my ($self, $col_idx) = @_;
    my $actual = $self->{lista_cols};
    while (defined $actual) {
        return $actual if ($actual->get_label() == $col_idx);
        last if ($actual->get_label() > $col_idx);
        $actual = $actual->get_next();
    }
    return undef;
}

sub _obtener_o_crear_cab_fila {
    my ($self, $fila_idx) = @_;

    if (!defined $self->{lista_filas} || $self->{lista_filas}->get_label() > $fila_idx) {
        my $nueva = NodoCabecera->new($fila_idx);
        $nueva->set_next($self->{lista_filas});
        $self->{lista_filas} = $nueva;
        return $nueva;
    }

    my $actual = $self->{lista_filas};
    while (defined $actual) {
        return $actual if $actual->get_label() == $fila_idx;
        if (!defined $actual->get_next() || $actual->get_next()->get_label() > $fila_idx) {
            my $nueva = NodoCabecera->new($fila_idx);
            $nueva->set_next($actual->get_next());
            $actual->set_next($nueva);
            return $nueva;
        }
        $actual = $actual->get_next();
    }
}

sub _obtener_o_crear_cab_col {
    my ($self, $col_idx) = @_;

    if (!defined $self->{lista_cols} || $self->{lista_cols}->get_label() > $col_idx) {
        my $nueva = NodoCabecera->new($col_idx);
        $nueva->set_next($self->{lista_cols});
        $self->{lista_cols} = $nueva;
        return $nueva;
    }

    my $actual = $self->{lista_cols};
    while (defined $actual) {
        return $actual if $actual->get_label() == $col_idx;
        if (!defined $actual->get_next() || $actual->get_next()->get_label() > $col_idx) {
            my $nueva = NodoCabecera->new($col_idx);
            $nueva->set_next($actual->get_next());
            $actual->set_next($nueva);
            return $nueva;
        }
        $actual = $actual->get_next();
    }
}

sub insertar {
    my ($self, $fila, $col, $valor) = @_;

    $self->{num_filas} = $fila + 1 if $fila >= $self->{num_filas};
    $self->{num_cols}  = $col + 1  if $col >= $self->{num_cols};

    my $cab_fila = $self->_obtener_o_crear_cab_fila($fila);
    my $cab_col  = $self->_obtener_o_crear_cab_col($col);

    my $existente = $self->obtener($fila, $col);
    if (defined $existente) {
        $existente->set_valor($valor);
        return;
    }

    my $nuevo = NodoDato->new($fila, $col, $valor);

    _insertar_horizontal($cab_fila, $nuevo);
    _insertar_vertical($cab_col, $nuevo);

    $self->{total_datos}++;
}

sub obtener {
    my ($self, $fila, $col) = @_;
    my $cab_fila = $self->buscar_cab_fila($fila);
    return undef unless defined $cab_fila;

    my $actual = $cab_fila->get_right();
    while (defined $actual) {
        return $actual if $actual->get_col() == $col;
        last if $actual->get_col() > $col;
        $actual = $actual->get_right();
    }
    return undef;
}

sub _insertar_horizontal {
    my ($cabecera, $nuevo) = @_;
    my $actual = $cabecera->get_right();

    if (!defined $actual || $actual->get_col() > $nuevo->get_col()) {
        $nuevo->set_right($actual);
        $actual->set_left($nuevo) if defined $actual;
        $cabecera->set_right($nuevo);
    } else {
        while (defined $actual->get_right() && $actual->get_right()->get_col() < $nuevo->get_col()) {
            $actual = $actual->get_right();
        }
        $nuevo->set_right($actual->get_right());
        $nuevo->set_left($actual);
        $actual->get_right()->set_left($nuevo) if defined $actual->get_right();
        $actual->set_right($nuevo);
    }
}

sub _insertar_vertical {
    my ($cabecera, $nuevo) = @_;
    my $actual = $cabecera->get_down();

    if (!defined $actual || $actual->get_fila() > $nuevo->get_fila()) {
        $nuevo->set_down($actual);
        $actual->set_up($nuevo) if defined $actual;
        $cabecera->set_down($nuevo);
    } else {
        while (defined $actual->get_down() && $actual->get_down()->get_fila() < $nuevo->get_fila()) {
            $actual = $actual->get_down();
        }
        $nuevo->set_down($actual->get_down());
        $nuevo->set_up($actual);
        $actual->get_down()->set_up($nuevo) if defined $actual->get_down();
        $actual->set_down($nuevo);
    }
}

1;