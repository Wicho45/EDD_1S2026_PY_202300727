package Reportes::ReporteCircular;

use strict;
use warnings;

sub generar_reporte {
    my ($class, $lista_proveedores) = @_;

    if ($lista_proveedores->is_empty()) {
        print "\n [!] La lista de proveedores esta vacia.\n";
        return;
    }

    my $dot_path = "imagenes/reporte_proveedores.dot";
    my $png_path = "imagenes/reporte_proveedores.png";

    open(my $fh, '>', $dot_path) or die "No se puede crear el archivo .dot: $!";

    print $fh "digraph G {\n";
    print $fh "  rankdir=TB;\n";
    print $fh "  nodesep=0.8;\n";
    print $fh "  ranksep=0.5;\n";
    print $fh "  node [shape=record, style=filled];\n";
    print $fh "  label=\"REPORTE DE PROVEEDORES Y DETALLE DE ENTREGAS\";\n";
    print $fh "  labelloc=\"t\";\n\n";

    my $actual_nodo_p = $lista_proveedores->{cabeza};
    my $id_p = 0;

    do {
        my $prov = $actual_nodo_p->get_data();
        my $info_p = "PROVEEDOR\\nNIT: " . $prov->get_nit() . "\\nEmpresa: " . $prov->get_nombre_empresa();
        
        print $fh "  prov$id_p [label=\"{ $info_p | <h> HISTORIAL }\", fillcolor=orange];\n";

        my $historial = $prov->get_historial();
        if (!$historial->isEmpty()) {
            my $actual_nodo_e = $historial->{head};
            my $id_e = 0;

            print $fh "  prov$id_p:h -> e_${id_p}_$id_e [style=dashed];\n";

            while (defined $actual_nodo_e) {
                my $entrega = $actual_nodo_e->get_data();
                
                my $info_e = "Factura: " . $entrega->get_numero_factura() . "\\n" .
                            "Fecha: " . $entrega->get_fecha_entrega() . "\\n" .
                            "Med: " . $entrega->get_codigo_medicamento() . "\\n" .
                            "Cant: " . $entrega->get_cantidad_entregada();

                print $fh "  e_${id_p}_$id_e [label=\"$info_e\", fillcolor=white];\n";

                if (defined $actual_nodo_e->get_next()) {
                    my $sig_e = $id_e + 1;
                    print $fh "  e_${id_p}_$id_e -> e_${id_p}_$sig_e;\n";
                }

                $actual_nodo_e = $actual_nodo_e->get_next();
                $id_e++;
            }
        }

        $actual_nodo_p = $actual_nodo_p->get_next();
        $id_p++;
    } while ($actual_nodo_p != $lista_proveedores->{cabeza});

    my $total_p = $id_p;
    for (my $i = 0; $i < $total_p; $i++) {
        my $sig = ($i + 1) % $total_p;
        if ($sig == 0) {
            print $fh "  prov$i -> prov$sig [label=\"inicio\", color=darkgreen, constraint=false];\n";
        } else {
            print $fh "  { rank=same; prov$i -> prov$sig; }\n";
        }
    } 

    print $fh "}\n";
    close($fh);

    system("dot -Tpng $dot_path -o $png_path");
    
    if ($? == 0) {
        print "\n Reporte generado exitosamente en: $png_path\n";
    } else {
        print "\n Error al generar la imagen PNG con Graphviz.\n";
    }
}

1;