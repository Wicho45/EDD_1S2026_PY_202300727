package Controlador::RegistrarEntrega;

use strict;
use warnings;

use Modelo::Entrega;
use constant Entrega => 'Modelo::Entrega';

use Reportes::ReporteListaDoblemente;
use constant ReporteListaDoblemente => 'Reportes::ReporteListaDoblemente';

use Reportes::ReporteCircular;
use constant ReporteCircular => 'Reportes::ReporteCircular';

sub registrarEntrega {
    my ($class, $lista_proveedores, $lista_inventario) = @_;

    #si la lista esta vacia
    if ($lista_proveedores->is_empty()){
        print "\nNo hay proveedores registrados. Por favor, registre un proveedor antes de registrar una entrega.\n";
        return 1;
    }

    my $continuar = "s";

    while ($continuar eq "s") {

        print "\nIngrese el NIT del proveedor: ";
        my $nit_proveedor = <STDIN>;
        chomp $nit_proveedor;

        print "\nIngrese la fecha de entrega: ";
        my $fecha_entrega = <STDIN>;
        chomp $fecha_entrega;

        print "\nIngrese el numero de factura: ";
        my $numero_factura = <STDIN>;
        chomp $numero_factura;

        print "\nIngrese el código del medicamento: ";
        my $codigo_medicamento = <STDIN>;
        chomp $codigo_medicamento;

        print "\nIngrese la cantidad de medicamento a entregar: ";
        my $cantidad_entregada = <STDIN>;
        chomp $cantidad_entregada;

        #verificar si hay stock disponible
        my $actual_inventario = $lista_inventario->{cabeza};
        my $medicamento_encontrado = 0;
        my $stock_suficiente = 0;

        my $nuevo = Entrega->new(
            $nit_proveedor,
            $fecha_entrega,
            $numero_factura,
            $codigo_medicamento,
            $cantidad_entregada
        );

        my $cabeza = $lista_proveedores->{cabeza};
        my $proveedor_encontrado = 0;

        if (defined $cabeza) {

            my $actual = $cabeza;

            do {

                if ($actual->get_data()->get_nit() eq $nit_proveedor) {

                    my $actual_inventario = $lista_inventario->{cabeza};
                    my $medicamento_encontrado = 0;

                    while (defined($actual_inventario)) {

                        if ($actual_inventario->get_data()->get_codigo_medicamento() eq $codigo_medicamento) {

                            my $stock_actual = $actual_inventario->get_data()->get_stock();

                            $actual_inventario->get_data()->set_stock(
                                $stock_actual + $cantidad_entregada
                            );
                            
                            ReporteListaDoblemente->generar_reporte($lista_inventario);

                            $medicamento_encontrado = 1;
                            last;
                        }

                        $actual_inventario = $actual_inventario->get_next();
                    }

                    if (!$medicamento_encontrado) {
                        print "\nMedicamento no encontrado en el inventario. Regístrelo primero.\n";
                        next;
                    }


                    $actual->get_data()->{historial}->insertar($nuevo);
                    ReporteCircular->generar_reporte($lista_proveedores);
                    ReporteListaDoblemente->generar_reporte($lista_inventario);  
                    
                    print "\nEntrega registrada exitosamente.\n";
                    $proveedor_encontrado = 1;
                    last;
                }

                $actual = $actual->get_next();

            } while ($actual ne $cabeza);
        }

        print "\nProveedor no encontrado.\n" unless $proveedor_encontrado;

        print "\n¿Desea registrar otro? (s/n): ";
        $continuar = <STDIN>;
        chomp $continuar;
    }

    return 1;
}

1;