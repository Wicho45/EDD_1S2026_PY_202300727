package Controlador::ConsultarDisponibilidad;

use strict;
use warnings;

sub consultarDisponibilidad {
    my ($class, $lista_inventario) = @_;
    my $continuar = "s";

    if ($lista_inventario->is_empty()) {
        print "\n[!] El inventario está vacío.\n";
        return;
    }

    while (lc($continuar) eq "s") {

        print "\nBuscar medicamento por código o nombre: ";
        my $busqueda = <STDIN>;
        chomp $busqueda;

        my $actual = $lista_inventario->{cabeza};
        my $encontrado = 0;

        while (defined $actual) {

            my $med = $actual->get_data();

            if (
                lc($med->get_codigo_medicamento()) eq lc($busqueda) ||
                lc($med->get_nombre_comercial()) eq lc($busqueda)
            ) {

                $encontrado = 1;

                my $stock     = $med->get_stock();
                my $nivel_min = $med->get_nivel_reorden();

                print "\n----------------------------------------";
                print "\nMedicamento: " . $med->get_nombre_comercial();
                print "\nCódigo: " . $med->get_codigo_medicamento();
                print "\nCantidad disponible: $stock";

                if ($stock < $nivel_min) {

                    print "\nEstado: Por debajo del nivel mínimo";

                    my $dias_estimados = 7;
                    print "\nTiempo estimado de reabastecimiento: $dias_estimados días";

                } else {

                    print "\nEstado: Stock suficiente";

                }

                print "\n----------------------------------------\n";

                if (lc($med->get_codigo_medicamento()) eq lc($busqueda)) {
                    last;
                }
            }

            $actual = $actual->get_next();
        }

        unless ($encontrado) {
            print "\n[!] Medicamento no encontrado en el inventario.\n";
        }

        print "\n¿Desea consultar otro medicamento? (s/n): ";
        $continuar = <STDIN>;
        chomp $continuar;
    }
    return 1;
}

1;