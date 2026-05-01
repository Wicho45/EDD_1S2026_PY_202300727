package Backend::Controlador::tablaHash;

use strict;
use warnings;

package NodoHash;

sub new {
    my ($class, $usuario) = @_;
    bless {
        usuario   => $usuario,
        siguiente => undef,
    }, $class;
}

sub get_usuario { return $_[0]->{usuario}; }
sub get_siguiente { return $_[0]->{siguiente}; }
sub set_siguiente { $_[0]->{siguiente} = $_[1]; }

package SlotNodo;

sub new {
    my ($class, $indice, $tipo) = @_;
    bless {
        indice => $indice,
        tipo => $tipo,
        lista_cabeza => undef,
        cantidad => 0,
        siguiente => undef,
    }, $class;
}

sub get_indice { return $_[0]->{indice}; }
sub get_tipo { return $_[0]->{tipo}; }
sub get_lista_cabeza { return $_[0]->{lista_cabeza}; }
sub get_cantidad { return $_[0]->{cantidad}; }
sub get_siguiente { return $_[0]->{siguiente}; }
sub set_lista_cabeza { $_[0]->{lista_cabeza} = $_[1]; }
sub set_cantidad { $_[0]->{cantidad} = $_[1]; }
sub set_siguiente { $_[0]->{siguiente} = $_[1]; }

package Backend::Controlador::tablaHash;

use constant CAPACIDAD => 4;

my $ETIQUETAS = {
    0 => 'TIPO-01',
    1 => 'TIPO-02',
    2 => 'TIPO-03',
    3 => 'TIPO-04',
};

sub new {
    my ($class) = @_;
    my $self = {
        cabeza => undef,
        total_elementos => 0,
    };
    bless $self, $class;

    my $ultimo = undef;
    for my $i (reverse 0 .. CAPACIDAD - 1) {
        my $slot = SlotNodo->new($i, $ETIQUETAS->{$i});
        $slot->set_siguiente($ultimo);
        $ultimo = $slot;
    }
    $self->{cabeza} = $ultimo;
    return $self;
}


sub _calcular_indice {
    my ($self, $tipo_str) = @_;
    return -1 unless defined $tipo_str;
    if ($tipo_str =~ /TIPO-0([1-4])/) {
        return int($1) - 1;
    }
    return -1;
}

sub _obtener_slot {
    my ($self, $indice) = @_;
    my $actual = $self->{cabeza};
    while (defined $actual) {
        return $actual if $actual->get_indice() == $indice;
        $actual = $actual->get_siguiente();
    }
    return undef;
}

sub insertar {
    my ($self, $usuario_obj) = @_;
    return 0 unless defined $usuario_obj;

    my $indice = $self->_calcular_indice($usuario_obj->get_tipo());
    my $slot = $self->_obtener_slot($indice);
    return 0 unless defined $slot;

    my $nuevo_nodo = NodoHash->new($usuario_obj);

    if (!defined $slot->get_lista_cabeza()) {
        $slot->set_lista_cabeza($nuevo_nodo);
    } else {
        my $actual = $slot->get_lista_cabeza();
        while (defined $actual->get_siguiente()) {
            $actual = $actual->get_siguiente();
        }
        $actual->set_siguiente($nuevo_nodo);
    }

    $slot->set_cantidad($slot->get_cantidad() + 1);
    $self->{total_elementos}++;
    return 1;
}

sub buscar_por_tipo {
    my ($self, $tipo) = @_;
    my $indice = $self->_calcular_indice($tipo);
    my $slot = $self->_obtener_slot($indice);
    return defined $slot ? $slot->get_lista_cabeza() : undef;
}

sub eliminar {
    my ($self, $numero_colegio, $tipo) = @_;
    my $indice = $self->_calcular_indice($tipo);
    my $slot = $self->_obtener_slot($indice);
    return 0 unless defined $slot;

    my $previo = undef;
    my $actual = $slot->get_lista_cabeza();

    while (defined $actual) {
        if ($actual->get_usuario()->get_numero_colegio() eq $numero_colegio) {
            if (!defined $previo) {
                $slot->set_lista_cabeza($actual->get_siguiente());
            } else {
                $previo->set_siguiente($actual->get_siguiente());
            }
            $slot->set_cantidad($slot->get_cantidad() - 1);
            $self->{total_elementos}--;
            return 1;
        }
        $previo = $actual;
        $actual = $actual->get_siguiente();
    }
    return 0;
}

sub get_cabeza_slots {
    return $_[0]->{cabeza};
}

1;