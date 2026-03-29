package Modelo::NodoB;

use strict;
use warnings;

sub new {
    my ($class) = @_;
    my $self = {
        claves_head => undef,
        hijos_head  => undef,
        num_claves  => 0,
        num_hijos   => 0,
    };
    bless $self, $class;
    return $self;
}

sub get_num_claves { return $_[0]->{num_claves}; }
sub get_num_hijos  { return $_[0]->{num_hijos}; }
sub get_claves_head { return $_[0]->{claves_head}; }
sub get_hijos_head  { return $_[0]->{hijos_head}; }

sub agregar_clave_ordenada {
    my ($self, $val) = @_;
    my $nueva = { val => $val, sig => undef };

    if (!defined($self->{claves_head}) || $val lt $self->{claves_head}->{val}) {
        $nueva->{sig} = $self->{claves_head};
        $self->{claves_head} = $nueva;
    } else {
        my $act = $self->{claves_head};
        while (defined($act->{sig}) && $act->{sig}->{val} lt $val) {
            $act = $act->{sig};
        }
        $nueva->{sig} = $act->{sig};
        $act->{sig} = $nueva;
    }
    $self->{num_claves}++;
}

sub eliminar_clave {
    my ($self, $val) = @_;
    return 0 unless defined($self->{claves_head});

    if ($self->{claves_head}->{val} eq $val) {
        $self->{claves_head} = $self->{claves_head}->{sig};
        $self->{num_claves}--;
        return 1;
    }

    my $ant = $self->{claves_head};
    while (defined($ant->{sig})) {
        if ($ant->{sig}->{val} eq $val) {
            $ant->{sig} = $ant->{sig}->{sig};
            $self->{num_claves}--;
            return 1;
        }
        $ant = $ant->{sig};
    }
    return 0;
}

sub get_clave_en_pos {
    my ($self, $pos) = @_;
    my $act = $self->{claves_head};
    for (my $i = 0; $i < $pos && defined($act); $i++) {
        $act = $act->{sig};
    }
    return $act ? $act->{val} : undef;
}

sub get_ultima_clave {
    my ($self) = @_;
    my $act = $self->{claves_head};
    return undef unless $act;
    $act = $act->{sig} while $act->{sig};
    return $act->{val};
}

sub agregar_hijo_al_final {
    my ($self, $nodo_hijo) = @_;
    my $nueva = { hijo => $nodo_hijo, sig => undef };

    if (!defined($self->{hijos_head})) {
        $self->{hijos_head} = $nueva;
    } else {
        my $act = $self->{hijos_head};
        $act = $act->{sig} while $act->{sig};
        $act->{sig} = $nueva;
    }
    $self->{num_hijos}++;
}

sub insertar_hijo_en_pos {
    my ($self, $pos, $nodo_hijo) = @_;
    my $nueva = { hijo => $nodo_hijo, sig => undef };

    if ($pos == 0) {
        $nueva->{sig} = $self->{hijos_head};
        $self->{hijos_head} = $nueva;
    } else {
        my $act = $self->{hijos_head};
        for (my $i = 0; $i < $pos - 1 && $act->{sig}; $i++) {
            $act = $act->{sig};
        }
        $nueva->{sig} = $act->{sig};
        $act->{sig} = $nueva;
    }
    $self->{num_hijos}++;
}

sub get_hijo_en_pos {
    my ($self, $pos) = @_;
    my $act = $self->{hijos_head};
    for (my $i = 0; $i < $pos && $act; $i++) {
        $act = $act->{sig};
    }
    return $act ? $act->{hijo} : undef;
}

sub eliminar_hijo_en_pos {
    my ($self, $pos) = @_;
    return undef unless $self->{hijos_head};

    if ($pos == 0) {
        my $h = $self->{hijos_head}->{hijo};
        $self->{hijos_head} = $self->{hijos_head}->{sig};
        $self->{num_hijos}--;
        return $h;
    }

    my $ant = $self->{hijos_head};
    for (my $i = 0; $i < $pos - 1 && $ant->{sig}; $i++) {
        $ant = $ant->{sig};
    }
    if ($ant->{sig}) {
        my $h = $ant->{sig}->{hijo};
        $ant->{sig} = $ant->{sig}->{sig};
        $self->{num_hijos}--;
        return $h;
    }
    return undef;
}

sub es_hoja { return !defined($_[0]->{hijos_head}); }

sub contiene_clave {
    my ($self, $val) = @_;
    my $act = $self->{claves_head};
    while ($act) {
        return 1 if $act->{val} eq $val;
        $act = $act->{sig};
    }
    return 0;
}

sub get_pos_clave {
    my ($self, $val) = @_;
    my $act = $self->{claves_head};
    my $i = 0;
    while ($act) {
        return $i if $act->{val} eq $val;
        $act = $act->{sig}; $i++;
    }
    return undef;
}

sub encontrar_pos_hijo {
    my ($self, $val) = @_;
    my $act = $self->{claves_head};
    my $i = 0;
    while ($act) {
        return $i if $val lt $act->{val};
        $act = $act->{sig}; $i++;
    }
    return $i;
}

1;