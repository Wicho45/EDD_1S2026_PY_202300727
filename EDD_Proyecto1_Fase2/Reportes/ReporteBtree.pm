package Reportes::ReporteBtree;

use strict;
use warnings;
use File::Path qw(make_path);
use utf8;

sub generar_reporte {
    my ($class, $arbol_b) = @_;

    if (!defined $arbol_b || $arbol_b->is_empty()) {
        return;
    }

    my $folder = "Imagenes";
    my $dot_path = "$folder/reporte_suministros_btree.dot";
    my $png_path = "$folder/reporte_suministros_btree.png";

    if (!-d $folder) {
        make_path($folder) or die $!;
    }

    open(my $fh, '>:encoding(UTF-8)', $dot_path) or die $!;

    print $fh "digraph G {\n";
    print $fh "    graph [ranksep=0.5, nodesep=0.5, fontname=\"Arial\"];\n";
    print $fh "    node [shape=record, fontname=\"Arial\", fontsize=10, style=filled];\n";
    print $fh "    edge [fontname=\"Arial\", fontsize=8];\n";
    print $fh "    label=\"ÁRBOL B (ORDEN 4) - INVENTARIO DE SUMINISTROS\";\n";
    print $fh "    labelloc=\"t\";\n\n";

    _generar_dot_recursivo($fh, $arbol_b->{raiz});

    print $fh "}\n";
    close($fh);

    my $dot_bin = "/opt/homebrew/bin/dot";
    my $comando = qq("$dot_bin" -Tpng "$dot_path" -o "$png_path");
    `$comando 2>&1`;
}

sub _generar_dot_recursivo {
    my ($fh, $nodo) = @_;
    return unless defined $nodo;

    my $node_id = sprintf("%s", $nodo);
    $node_id =~ s/[^a-zA-Z0-9]//g;

    my $num_claves = $nodo->get_num_claves();
    my $max_claves = 4; 

    my $color = ($num_claves >= $max_claves) ? "yellow" : "palegreen";

    my @celdas;
    for (my $i = 0; $i < $num_claves; $i++) {
        my $suministro = $nodo->get_clave_en_pos($i);
        my $txt = $suministro->get_codigo();
        push @celdas, "<p$i> | $txt |";
    }
    push @celdas, "<p$num_claves>"; 

    my $label = "{ Claves: $num_claves/$max_claves | { " . join(" ", @celdas) . " } }";

    print $fh "    \"$node_id\" [label=\"$label\", fillcolor=\"$color\"];\n";

    if (!$nodo->es_hoja()) {
        for (my $i = 0; $i <= $num_claves; $i++) {
            my $hijo = $nodo->get_hijo_en_pos($i);
            if (defined $hijo) {
                my $hijo_id = sprintf("%s", $hijo);
                $hijo_id =~ s/[^a-zA-Z0-9]//g;
                print $fh "    \"$node_id\":p$i -> \"$hijo_id\";\n";
                _generar_dot_recursivo($fh, $hijo);
            }
        }
    }
}

1;