package Reportes::ReporteAvl;

use strict;
use warnings;
use File::Path qw(make_path);
use utf8;

sub generar_reporte {
    my ($class, $arbol_avl) = @_;

    if (!defined $arbol_avl || $arbol_avl->is_empty()) {
        return;
    }

    my $folder = "Imagenes";
    my $dot_path = "$folder/reporte_personal_avl.dot";
    my $png_path = "$folder/reporte_personal_avl.png";

    if (!-d $folder) {
        make_path($folder) or die $!;
    }

    open(my $fh, '>:encoding(UTF-8)', $dot_path) or die $!;

    print $fh "digraph G {\n";
    print $fh "    graph [nodesep=0.5, ranksep=0.5, fontname=\"Arial\"];\n";
    print $fh "    node [shape=circle, fontname=\"Arial\", fontsize=9, style=filled, fillcolor=white, width=1.2, fixedsize=true];\n";
    print $fh "    edge [fontname=\"Arial\", fontsize=8];\n";
    print $fh "    label=\"ÁRBOL AVL - PERSONAL MÉDICO\";\n";
    print $fh "    labelloc=\"t\";\n\n";

    _generar_dot_recursivo($fh, $arbol_avl->{root});

    print $fh "}\n";
    close($fh);

    my $dot_bin = "/opt/homebrew/bin/dot";
    my $comando = qq("$dot_bin" -Tpng "$dot_path" -o "$png_path");
    `$comando 2>&1`;
}

sub _generar_dot_recursivo {
    my ($fh, $nodo) = @_;

    return unless defined $nodo;

    my $usuario = $nodo->get_data();
    my $node_id = sprintf("%s", $usuario);
    $node_id =~ s/[^a-zA-Z0-9]//g; 

    my $colegio = $usuario->get_numero_colegio();
    my $nombre  = $usuario->get_username();
    my $depto   = $usuario->get_departamento();

    my $label = "$colegio\n$nombre\n$depto";

    print $fh "    \"$node_id\" [label=\"$label\"];\n";

    if (defined $nodo->get_left()) {
        my $izq_id = sprintf("%s", $nodo->get_left()->get_data());
        $izq_id =~ s/[^a-zA-Z0-9]//g;
        print $fh "    \"$node_id\" -> \"$izq_id\" [label=\"L\"];\n";
        _generar_dot_recursivo($fh, $nodo->get_left());
    }

    if (defined $nodo->get_right()) {
        my $der_id = sprintf("%s", $nodo->get_right()->get_data());
        $der_id =~ s/[^a-zA-Z0-9]//g;
        print $fh "    \"$node_id\" -> \"$der_id\" [label=\"R\"];\n";
        _generar_dot_recursivo($fh, $nodo->get_right());
    }
}

1;