package Reportes::ReporteListaCircularDoble;

use strict;
use warnings;

sub generar_reporte {
    my ($class, $lista) = @_;

    if ($lista->is_empty()) {
        print "\n [!] La lista de reabastecimientos esta vacia.\n";
        return;
    }

    my $dot_path = "imagenes/reabastecimientos.dot";
    my $png_path = "imagenes/reabastecimientos.png";

    open(my $fh, '>', $dot_path) or die "No se puede crear el archivo .dot: $!";

    print $fh "digraph G {\n";
    print $fh "  rankdir=LR;\n";
    print $fh "  node [shape=record, style=filled, fillcolor=azure];\n";
    print $fh "  label=\"LISTA CIRCULAR DOBLEMENTE ENLAZADA - REABASTECIMIENTOS\";\n";
    print $fh "  labelloc=\"t\";\n\n";

    my $actual = $lista->{cabeza};
    my $id = 0;

    do {
        my $dato = $actual->get_data();
        
        my $info = "Dep: " . $dato->get_departamento_solicitante() . "\\n" .
                    "Med: " . $dato->get_medicamento_requerido() . "\\n" .
                    "Cant: " . $dato->get_cantidad_solicitada() . "\\n" .
                    "Prioridad: " . $dato->get_prioridad();

        print $fh "  nodo$id [label=\"{ <prev> | $info | <next> }\"];\n";
        
        $actual = $actual->get_next();
        $id++;
    } while ($actual != $lista->{cabeza});

    my $total = $id;
    for (my $i = 0; $i < $total; $i++) {
        my $siguiente = ($i + 1) % $total;
        
        print $fh "  nodo$i:next -> nodo$siguiente:prev [color=blue];\n";
        print $fh "  nodo$siguiente:prev -> nodo$i:next [color=red];\n";
    }

    print $fh "}\n";
    close($fh);

    system("dot -Tpng $dot_path -o $png_path");
    
    if ($? == 0) {
        print "\nReporte de reabastecimientos (DOT y PNG) creado en 'imagenes/'.\n";
    } else {
        print "\nError: No se pudo generar el PNG. Verifica que Graphviz este instalado.\n";
    }
}

1;