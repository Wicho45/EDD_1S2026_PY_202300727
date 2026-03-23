package Reportes::ReporteMatriz;

use strict;
use warnings;

sub generar_reporte {
    my ($class, $matriz, $mapa_meds, $mapa_labs) = @_;

    if (!defined $matriz || $matriz->{total_datos} == 0) {
        print "\n [!] La matriz esta vacia. No hay nada que reportar.\n";
        return;
    }

    my $dot_path = "imagenes/matriz_inventario.dot";
    my $png_path = "imagenes/matriz_inventario.png";

    open(my $fh, '>', $dot_path) or die "No se pudo crear el archivo .dot: $!";

    print $fh "digraph G {\n";
    print $fh "    nodesep=0.5;\n";
    print $fh "    ranksep=0.5;\n";
    print $fh "    node [shape=box, style=filled, fontname=\"Arial Bold\", fontsize=10];\n";
    print $fh "    edge [dir=both, arrowsize=0.7];\n";
    print $fh "    label=\"MATRIZ DISPERSA DE INVENTARIO\\n(Medicamento vs Laboratorio)\";\n";
    print $fh "    labelloc=\"t\";\n\n";

    print $fh "    raiz [label=\"Medicamento\\n/ Laboratorio\", fillcolor=lightgray, group=0];\n\n";

    my $cab_col = $matriz->{lista_cols};
    my @cols_ids = ();
    while (defined $cab_col) {
        my $col_idx = $cab_col->get_label();
        my $nombre_lab = _obtener_nombre($mapa_labs, $col_idx);
        my $group = $col_idx + 1;
        
        print $fh "    col$col_idx [label=\"$nombre_lab\", fillcolor=lightblue, group=$group];\n";
        push @cols_ids, $col_idx;
        $cab_col = $cab_col->get_next();
    }

    print $fh "    { rank=same; raiz; " . join("; ", map { "col$_" } @cols_ids) . "; }\n\n";

    my $cab_fila = $matriz->{lista_filas};
    my @filas_ids = ();
    
    while (defined $cab_fila) {
        my $fila_idx = $cab_fila->get_label();
        my $nombre_med = _obtener_nombre($mapa_meds, $fila_idx);
        push @filas_ids, $fila_idx;

        print $fh "    fila$fila_idx [label=\"$nombre_med\", fillcolor=lightpink, group=0];\n";

        my $nodo = $cab_fila->get_right();
        my @nodos_en_esta_fila = ("fila$fila_idx");
        
        while (defined $nodo) {
            my $c = $nodo->get_col();
            my $med = $nodo->get_valor();
            my $group = $c + 1;
            my $info = "Stock: " . $med->get_stock() . "\\nPrecio: \$" . $med->get_precio();
            
            print $fh "    n_${fila_idx}_$c [label=\"$info\", fillcolor=white, group=$group];\n";
            push @nodos_en_esta_fila, "n_${fila_idx}_$c";
            
            $nodo = $nodo->get_right();
        }

        print $fh "    { rank=same; " . join("; ", @nodos_en_esta_fila) . "; }\n";
        $cab_fila = $cab_fila->get_next();
    }

    $cab_fila = $matriz->{lista_filas};
    while (defined $cab_fila) {
        my $f = $cab_fila->get_label();
        my $nodo = $cab_fila->get_right();
        my $ant = "fila$f";
        while (defined $nodo) {
            my $act = "n_${f}_" . $nodo->get_col();
            print $fh "    $ant -> $act [color=green4];\n";
            $ant = $act;
            $nodo = $nodo->get_right();
        }
        $cab_fila = $cab_fila->get_next();
    }

    $cab_col = $matriz->{lista_cols};
    while (defined $cab_col) {
        my $c = $cab_col->get_label();
        my $nodo = $cab_col->get_down();
        my $ant = "col$c";
        while (defined $nodo) {
            my $act = "n_" . $nodo->get_fila() . "_$c";
            print $fh "    $ant -> $act [color=blue4];\n";
            $ant = $act;
            $nodo = $nodo->get_down();
        }
        $cab_col = $cab_col->get_next();
    }

    if (@cols_ids) { print $fh "    raiz -> col$cols_ids[0] [style=invis];\n"; }
    if (@filas_ids) { print $fh "    raiz -> fila$filas_ids[0] [style=invis];\n"; }

    for (my $i = 0; $i < $#cols_ids; $i++) {
        print $fh "    col$cols_ids[$i] -> col$cols_ids[$i+1] [style=invis];\n";
    }
    for (my $i = 0; $i < $#filas_ids; $i++) {
        print $fh "    fila$filas_ids[$i] -> fila$filas_ids[$i+1] [style=invis];\n";
    }

    print $fh "}\n";
    close($fh);

    my $cmd = "dot -Tpng $dot_path -o $png_path";
    system($cmd);
    
    if ($? == 0) {
        print "\n [OK] Reporte Matriz generado: $png_path\n";
    } else {
        print "\n [!] Error al compilar Graphviz. Verifique su instalacion.\n";
    }
}

sub _obtener_nombre {
    my ($lista, $indice) = @_;
    my $actual = $lista->{head};
    my $i = 0;
    while (defined $actual) {
        return $actual->get_data() if $i == $indice;
        $actual = $actual->get_next();
        $i++;
    }
    return "ID $indice";
}

1;