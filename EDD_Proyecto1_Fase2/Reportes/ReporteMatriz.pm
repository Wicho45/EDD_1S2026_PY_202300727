package Reportes::ReporteMatriz;

use strict;
use warnings;
use File::Path qw(make_path);

sub generar_reporte {
    my ($class, $matriz) = @_;

    return if !$matriz || $matriz->{total_datos} == 0;

    my $folder = "Imagenes";
    my $dot_path = "$folder/matriz_proveedores.dot";
    my $png_path = "$folder/matriz_proveedores.png";
    make_path($folder) if !-d $folder;

    open(my $fh, '>', $dot_path) or die $!;

    print $fh "digraph G {\n";
    print $fh "    graph [pad=\"0.5\", nodesep=\"0.5\", ranksep=\"0.5\", newrank=true];\n";
    print $fh "    node [fontname=\"Arial\", fontsize=10];\n";
    print $fh "    edge [dir=both, arrowsize=0.6];\n";

    print $fh "    raiz [label=\"Proveedores\\nvs\\nFabricantes\", shape=box, style=filled, fillcolor=lightgray, group=0];\n";

    my $c_cab = $matriz->{lista_cols};
    my @cols_ids;
    my $idx = 1;
    while ($c_cab) {
        my $id = $c_cab->get_label();
        print $fh "    \"col_$id\" [label=\"$id\", shape=box, style=filled, fillcolor=lightblue, group=$idx];\n";
        push @cols_ids, "col_$id";
        $c_cab = $c_cab->get_next();
        $idx++;
    }

    if (@cols_ids) {
        print $fh "    raiz -> \"$cols_ids[0]\";\n";
        for (my $i = 0; $i < $#cols_ids; $i++) {
            print $fh "    \"$cols_ids[$i]\" -> \"$cols_ids[$i+1]\";\n";
        }
        print $fh "    { rank=same; raiz; " . join("; ", map { "\"$_\"" } @cols_ids) . " }\n";
    }

    my $f_cab = $matriz->{lista_filas};
    my @filas_ids;
    while ($f_cab) {
        my $f_id = $f_cab->get_label();
        print $fh "    \"fila_$f_id\" [label=\"$f_id\", shape=box, style=filled, fillcolor=lightpink, group=0];\n";
        push @filas_ids, "fila_$f_id";

        my $nodo = $f_cab->get_right();
        my @nodos_fila = ("\"fila_$f_id\"");
        
        while ($nodo) {
            my $c_id = $nodo->get_col();
            my $val = $nodo->get_valor();
            
            my $grupo_col = 0;
            my $temp_c = $matriz->{lista_cols};
            my $c_count = 1;
            while($temp_c){
                if($temp_c->get_label() eq $c_id){ $grupo_col = $c_count; last; }
                $temp_c = $temp_c->get_next(); $c_count++;
            }

            print $fh "    \"n_${f_id}_${c_id}\" [label=\"$val\", shape=circle, style=filled, fillcolor=white, group=$grupo_col, width=0.6, fixedsize=true];\n";
            push @nodos_fila, "\"n_${f_id}_${c_id}\"";
            $nodo = $nodo->get_right();
        }
        
        print $fh "    { rank=same; " . join("; ", @nodos_fila) . " }\n";
        $f_cab = $f_cab->get_next();
    }

    if (@filas_ids) {
        print $fh "    raiz -> \"$filas_ids[0]\";\n";
        for (my $i = 0; $i < $#filas_ids; $i++) {
            print $fh "    \"$filas_ids[$i]\" -> \"$filas_ids[$i+1]\";\n";
        }
    }

    $f_cab = $matriz->{lista_filas};
    while ($f_cab) {
        my $f_id = $f_cab->get_label();
        my $nodo = $f_cab->get_right();
        my $ant = "fila_$f_id";
        while ($nodo) {
            my $act = "n_${f_id}_" . $nodo->get_col();
            print $fh "    \"$ant\" -> \"$act\";\n";
            $ant = $act;
            $nodo = $nodo->get_right();
        }
        $f_cab = $f_cab->get_next();
    }

    $c_cab = $matriz->{lista_cols};
    while ($c_cab) {
        my $c_id = $c_cab->get_label();
        my $nodo = $c_cab->get_down();
        my $ant = "col_$c_id";
        while ($nodo) {
            my $act = "n_" . $nodo->get_fila() . "_$c_id";
            print $fh "    \"$ant\" -> \"$act\";\n";
            $ant = $act;
            $nodo = $nodo->get_down();
        }
        $c_cab = $c_cab->get_next();
    }

    print $fh "}\n";
    close($fh);

    my $dot_bin = "/opt/homebrew/bin/dot";
    system(qq("$dot_bin" -Tpng "$dot_path" -o "$png_path"));
}

1;