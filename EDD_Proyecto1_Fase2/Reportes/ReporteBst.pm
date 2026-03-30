package Reportes::ReporteBst;

use strict;
use warnings;
use File::Path qw(make_path);
use utf8;

sub generar_reporte {
    my ($class, $arbol_bst) = @_;

    if (!defined $arbol_bst || $arbol_bst->is_empty()) {
        return;
    }

    my $folder = "Imagenes";
    my $dot_path = "$folder/reporte_equipo_bst.dot";
    my $png_path = "$folder/reporte_equipo_bst.png";

    if (!-d $folder) {
        make_path($folder) or die $!;
    }

    open(my $fh, '>:encoding(UTF-8)', $dot_path) or die $!;

    print $fh "digraph G {\n";
    print $fh "    graph [ordering=\"out\", ranksep=0.5, nodesep=0.5, fontname=\"Arial\"];\n";
    print $fh "    node [shape=record, fontname=\"Arial\", fontsize=10, style=filled, fillcolor=white];\n";
    print $fh "    edge [fontname=\"Arial\", fontsize=8];\n";
    print $fh "    label=\"INVENTARIO DE EQUIPOS MÉDICOS\";\n";
    print $fh "    labelloc=\"t\";\n\n";

    _generar_dot_recursivo($fh, $arbol_bst->{root}, 1);

    print $fh "}\n";
    close($fh);

    my $dot_bin = "/opt/homebrew/bin/dot";
    my $comando = qq("$dot_bin" -Tpng "$dot_path" -o "$png_path");
    `$comando 2>&1`;
}

sub _generar_dot_recursivo {
    my ($fh, $nodo, $es_raiz) = @_;

    return unless defined $nodo;

    my $equipo = $nodo->get_data();
    my $node_id = sprintf("%s", $equipo);
    $node_id =~ s/[^a-zA-Z0-9]//g; 

    my $codigo = _escapar_dot($equipo->get_codigo());
    my $nombre = _escapar_dot($equipo->get_nombre());
    my $marca  = _escapar_dot($equipo->get_fabricante());
    my $cant   = _escapar_dot($equipo->get_cantidad());

    my $label = "{ <f0> L | {ID: $codigo | $nombre | Fab: $marca | Cant: $cant} | <f2> R }";

    my $color_relleno = "white";
    my $perifericos = 1;

    if ($es_raiz) {
        $color_relleno = "lightblue";
        $perifericos = 2;
    } elsif ($nodo->es_hoja()) {
        $color_relleno = "springgreen";
    }

    print $fh "    \"$node_id\" [label=\"$label\", fillcolor=\"$color_relleno\", periferies=$perifericos];\n";

    if (defined $nodo->get_left()) {
        my $izq_id = sprintf("%s", $nodo->get_left()->get_data());
        $izq_id =~ s/[^a-zA-Z0-9]//g;
        print $fh "    \"$node_id\":f0 -> \"$izq_id\";\n";
        _generar_dot_recursivo($fh, $nodo->get_left(), 0);
    }

    if (defined $nodo->get_right()) {
        my $der_id = sprintf("%s", $nodo->get_right()->get_data());
        $der_id =~ s/[^a-zA-Z0-9]//g;
        print $fh "    \"$node_id\":f2 -> \"$der_id\";\n";
        _generar_dot_recursivo($fh, $nodo->get_right(), 0);
    }
}

sub _escapar_dot {
    my ($texto) = @_;
    return "" unless defined $texto;
    $texto =~ s/\\/\\\\/g;
    $texto =~ s/{/\\{/g;
    $texto =~ s/}/\\}/g;
    $texto =~ s/\|/\\\|/g;
    $texto =~ s/"/\\"/g;
    $texto =~ s/\n/ /g;
    return $texto;
}

1;