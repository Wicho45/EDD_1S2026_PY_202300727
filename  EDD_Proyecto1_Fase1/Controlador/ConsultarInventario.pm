package Controlador::ConsultarInventario;

use strict;
use warnings;

sub consultar_por_medicina {
    my ($class, $matriz, $mapa_meds, $mapa_labs) = @_;
    my $hacer_busqueda = "s";

    while (lc($hacer_busqueda) eq "s") {
        print "\nIngrese el nombre del medicamento: ";
        my $nombre_med = <STDIN>;
        chomp $nombre_med;

        my $fila_idx = -1;
        my $actual_med = $mapa_meds->{head};
        my $contador = 0;

        while (defined $actual_med) {

            my $nombre_en_lista = $actual_med->get_data(); 
            
            if (lc($nombre_en_lista) eq lc($nombre_med)) {
                $fila_idx = $contador;
                last;
            }
            $actual_med = $actual_med->get_next();
            $contador++;
        }

        if ($fila_idx == -1) {
            print "\n [!] No se encontraron registros para la medicina: $nombre_med\n";
        } else {
            my $cab_fila = $matriz->buscar_cab_fila($fila_idx);
            
            if (!defined $cab_fila || !defined $cab_fila->get_right()) {
                print "\n [!] No hay laboratorios asociados a este medicamento.\n";
            } else {
                print "\n" . ("-" x 60);
                print "\n COMPARATIVA DE PRECIOS: " . uc($nombre_med);
                print "\n" . ("-" x 60);
                printf("\n%-25s | %-12s | %-10s", "Laboratorio", "Precio ", "Stock");
                print "\n" . ("-" x 60);

                my $nodo_actual = $cab_fila->get_right();
                while (defined $nodo_actual) {
                    my $col_idx = $nodo_actual->get_col();
                    my $nombre_lab = _obtener_nombre_mapeado($mapa_labs, $col_idx);
                    my $med = $nodo_actual->get_valor();

                    printf("\n%-25s | %-12.2f | %-10d", 
                            $nombre_lab, 
                            $med->get_precio(), 
                            $med->get_stock());

                    $nodo_actual = $nodo_actual->get_right();
                }
                print "\n" . ("-" x 60) . "\n";
            }
        }

        print "\n¿Desea realizar otra búsqueda? (s/n): ";
        $hacer_busqueda = <STDIN>;
        chomp $hacer_busqueda;
    }
    return 1;
}

sub _obtener_nombre_mapeado {
    my ($lista, $indice) = @_;
    my $actual = $lista->{head};
    my $i = 0;
    while (defined $actual) {
        return $actual->get_data() if $i == $indice;
        $actual = $actual->get_next();
        $i++;
    }
    return "Desconocido";
}

1;