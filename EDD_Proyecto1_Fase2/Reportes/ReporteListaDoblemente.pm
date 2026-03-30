package Reportes::ReporteListaDoblemente;

use strict;
use warnings;
use File::Path qw(make_path);

sub generar_reporte {
    my ($class, $lista_inventario) = @_;

    return if !$lista_inventario || $lista_inventario->is_empty();

    my $folder = "Imagenes";
    my $ruta_dot = "$folder/reporte_inventario.dot";
    my $ruta_png = "$folder/reporte_inventario.png";

    make_path($folder) if !-d $folder;

    open(my $fh, '>:encoding(UTF-8)', $ruta_dot) or die $!;

    print $fh "digraph G {\n";
    print $fh "    rankdir=LR;\n";
    print $fh "    nodesep=0.5;\n";
    print $fh "    node [shape=box, style=filled, fontname=\"Arial\", fontsize=10, width=2.5];\n";
    print $fh "    edge [dir=both, arrowsize=0.7];\n";
    print $fh "    label=\"INVENTARIO DE MEDICAMENTOS\"; labelloc=\"t\";\n\n";

    print $fh "    inicio [label=\"INICIO\", shape=box, fillcolor=\"gray\", style=\"filled,bold\"];\n";
    print $fh "    fin [label=\"FIN\", shape=box, fillcolor=\"gray\", style=\"filled,bold\"];\n\n";

    my $actual = $lista_inventario->{cabeza};
    my $contador = 0;
    my @nodos;

    while (defined $actual) {
        my $m = $actual->get_data();
        my $codigo = $m->get_codigo_medicamento();
        my $nombre = $m->get_nombre_comercial();
        my $stock  = $m->get_stock();
        my $vence  = $m->get_fecha_vencimiento();

        my $color = "palegreen";
        if ($stock < 100) {
            $color = "red";
        } elsif ($vence lt "2027-01-01") {
            $color = "yellow";
        }

        print $fh "    nodo$contador [label=\"ID: $codigo\\n$nombre\\nStock: $stock\\nVence: $vence\", fillcolor=\"$color\"];\n";
        push @nodos, "nodo$contador";

        $actual = $actual->get_next();
        $contador++;
    }

    print $fh "    inicio -> $nodos[0];\n" if @nodos;

    for (my $i = 0; $i < @nodos - 1; $i++) {
        print $fh "    $nodos[$i] -> $nodos[$i+1];\n";
    }

    print $fh "    $nodos[-1] -> fin;\n" if @nodos;

    print $fh "}\n";
    close $fh;

    my $dot_bin = "/opt/homebrew/bin/dot";
    system(qq("$dot_bin" -Tpng "$ruta_dot" -o "$ruta_png"));
}

1;