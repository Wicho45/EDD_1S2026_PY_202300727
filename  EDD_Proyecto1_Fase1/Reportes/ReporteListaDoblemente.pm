package Reportes::ReporteListaDoblemente;

use strict;
use warnings;
use POSIX qw(strftime);

sub generar_reporte {

    my ($class, $lista_inventario) = @_;

    return if $lista_inventario->is_empty();

    my $ruta_dot = "Imagenes/reporte_inventario.dot";
    my $ruta_png = "Imagenes/reporte_inventario.png";

    open(my $fh, '>', $ruta_dot) or die "No se pudo crear el archivo DOT";

    print $fh "digraph ListaDoblemente {\n";
    print $fh "rankdir=LR;\n";
    print $fh "node [shape=record, style=filled];\n\n";

    my $actual = $lista_inventario->{cabeza};
    my $contador = 0;

    my @nodos;

    while (defined $actual) {

        my $med = $actual->get_data();

        my $codigo  = $med->get_codigo_medicamento();
        my $nombre  = $med->get_nombre_comercial();
        my $stock   = $med->get_stock();
        my $fecha   = $med->get_vencimiento();
        my $minimo  = $med->get_nivel_reorden();

        my $color = "palegreen";

        if ($stock < $minimo) {
            $color = "lightcoral";
        }
        elsif (_proximo_a_vencer($fecha)) {
            $color = "khaki";
        }

        print $fh "nodo$contador [label=\"{ $codigo | $nombre | Stock: $stock | Vence: $fecha }\", fillcolor=\"$color\"];\n";

        push @nodos, "nodo$contador";

        $actual = $actual->get_next();
        $contador++;
    }

    for (my $i = 0; $i < @nodos - 1; $i++) {
        print $fh "$nodos[$i] -> $nodos[$i+1];\n";
        print $fh "$nodos[$i+1] -> $nodos[$i];\n";
    }

    print $fh "cabeza [shape=plaintext label=\"Cabeza\"];\n";
    print $fh "ultimo [shape=plaintext label=\"Último\"];\n";

    print $fh "cabeza -> $nodos[0];\n";
    print $fh "ultimo -> $nodos[-1];\n";

    print $fh "}\n";

    close $fh;

    system("dot -Tpng $ruta_dot -o $ruta_png");

    print "\nReporte de inventario generado en $ruta_png\n";
}

sub _proximo_a_vencer {

    my ($fecha) = @_;

    my ($anio, $mes, $dia) = split(/-/, $fecha);
    my $fecha_epoch = eval { POSIX::mktime(0,0,0,$dia,$mes-1,$anio-1900) };

    return 0 unless $fecha_epoch;

    my $hoy = time();
    my $diferencia = ($fecha_epoch - $hoy) / (60*60*24);

    return ($diferencia <= 30 && $diferencia > 0);
}

1;