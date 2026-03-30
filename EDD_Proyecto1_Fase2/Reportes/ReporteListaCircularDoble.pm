package Reportes::ReporteListaCircularDoble;

use strict;
use warnings;
use File::Path qw(make_path);

sub generar_reporte {
    my ($class, $lista) = @_;

    return if !defined $lista || $lista->is_empty();

    my $folder = "Imagenes";
    my $dot_path = "$folder/reporte_proveedores.dot";
    my $png_path = "$folder/reporte_proveedores.png";

    make_path($folder) if !-d $folder;

    open(my $fh, '>:encoding(UTF-8)', $dot_path) or die $!;

    print $fh "digraph G {\n";
    print $fh "    rankdir=LR;\n";
    print $fh "    nodesep=0.6;\n";
    print $fh "    ranksep=0.6;\n";
    print $fh "    splines=true;\n";
    print $fh "    node [shape=record, style=\"rounded,filled\", fillcolor=\"lightgreen\", color=\"green\", fontname=\"Arial\", fontsize=11, width=2.5, height=1.0];\n";
    print $fh "    edge [color=\"blue\", arrowsize=0.8];\n";
    print $fh "    label=\"LISTA CIRCULAR DOBLE - PROVEEDORES\"; labelloc=\"t\"; fontsize=18; fontname=\"Arial Bold\";\n\n";

    my $actual = $lista->{cabeza};
    my $id = 0;
    my @nodos;

    do {
        my $p = $actual->get_data();
        my $nit = $p->get_nit();
        my $nom = $p->get_nombre_empresa();
        my $tel = $p->get_telefono();

        my $label = "{ <prev> | {\\N | NIT: $nit\\n$nom\\nTel: $tel} | <next> }";

        print $fh "    nodo$id [label=\"$label\"];\n";
        push @nodos, "nodo$id";

        $actual = $actual->get_next();
        $id++;
    } while ($actual != $lista->{cabeza});

    for (my $i = 0; $i < @nodos - 1; $i++) {
        print $fh "    $nodos[$i]:next -> $nodos[$i+1]:prev [dir=both];\n";
    }

    if (@nodos > 1) {
        my $last = $nodos[-1];
        my $first = $nodos[0];
        print $fh "    $last:next -> $first:prev [dir=both, color=\"red\", penwidth=1.5, label=\"circular\"];\n";
    }

    print $fh "}\n";
    close($fh);

    my $dot_bin = "/opt/homebrew/bin/dot";
    system(qq("$dot_bin" -Tpng "$dot_path" -o "$png_path"));
}

1;