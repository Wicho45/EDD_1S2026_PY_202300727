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
    print $fh "    node [shape=box, style=filled, fontname=\"Helvetica\", fontsize=12, width=1.5, height=0.6];\n";
    print $fh "    edge [dir=both, arrowsize=0.6];\n";
    print $fh "    newrank=true;\n";
    print $fh "    nodesep=0.4;\n";
    print $fh "    ranksep=0.4;\n";

    # Nodo Raíz
    print $fh "    raiz [label=\"Proveedor\\n/ Fabricante\", fillcolor=lightgray, group=0];\n";

    # Crear Cabeceras de Columnas (Fabricantes)
    my $c_cab = $matriz->{lista_cols};
    my @cols_list;
    my $cont_c = 1;
    while ($c_cab) {
        my $id = $c_cab->get_label();
        print $fh "    \"col_$id\" [label=\"$id\", fillcolor=lightblue, group=$cont_c];\n";
        push @cols_list, "col_$id";
        $c_cab = $c_cab->get_next();
        $cont_c++;
    }

    # Conectar cabeceras de columnas (Horizontal)
    if (@cols_list) {
        print $fh "    raiz -> \"$cols_list[0]\";\n";
        for (my $i = 0; $i < $#cols_list; $i++) {
            print $fh "    \"$cols_list[$i]\" -> \"$cols_list[$i+1]\";\n";
        }
        print $fh "    { rank=same; raiz; " . join("; ", map { "\"$_\"" } @cols_list) . " }\n";
    }

    # Crear Filas y Nodos de Datos
    my $f_cab = $matriz->{lista_filas};
    my @filas_cab_list;
    while ($f_cab) {
        my $f_id = $f_cab->get_label();
        print $fh "    \"fila_$f_id\" [label=\"$f_id\", fillcolor=lightpink, group=0];\n";
        push @filas_cab_list, "fila_$f_id";

        my $nodo = $f_cab->get_right();
        my @nodos_en_fila = ("\"fila_$f_id\"");
        
        while ($nodo) {
            my $c_id = $nodo->get_col();
            my $val = $nodo->get_valor();
            
            # Encontrar el grupo (índice de la columna)
            my $grupo_col = 0;
            for (my $i=0; $i<@cols_list; $i++) {
                if ($cols_list[$i] eq "col_$c_id") { $grupo_col = $i + 1; last; }
            }

            print $fh "    \"n_${f_id}_${c_id}\" [label=\"Cant: $val\", fillcolor=white, group=$grupo_col];\n";
            push @nodos_en_fila, "\"n_${f_id}_${c_id}\"";
            $nodo = $nodo->get_right();
        }
        
        # Alinear fila horizontalmente
        print $fh "    { rank=same; " . join("; ", @nodos_en_fila) . " }\n";
        $f_cab = $f_cab->get_next();
    }

    # Conectar cabeceras de filas (Vertical)
    if (@filas_cab_list) {
        print $fh "    raiz -> \"$filas_cab_list[0]\";\n";
        for (my $i = 0; $i < $#filas_cab_list; $i++) {
            print $fh "    \"$filas_cab_list[$i]\" -> \"$filas_cab_list[$i+1]\";\n";
        }
    }

    # Conexiones de Datos HORIZONTALES
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

    # Conexiones de Datos VERTICALES
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