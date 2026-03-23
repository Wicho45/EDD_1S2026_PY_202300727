package Controlador::ProcesarReabastecimiento;

use strict;
use warnings;

use Modelo::Reabastecimiento;
use constant Reabastecimiento => 'Modelo::Reabastecimiento';

use Reportes::ReporteListaDoblemente;
use constant ReporteListaDoblemente => 'Reportes::ReporteListaDoblemente';

use Reportes::ReporteListaCircularDoble;
use constant ReporteListaCircularDoble => 'Reportes::ReporteListaCircularDoble';

sub procesarReabastecimiento {
    my ($class, $lista_inventario, $lista_reabastecimientos) = @_;

    if ($lista_reabastecimientos->is_empty()) {
        print "\nNo hay solicitudes de reabastecimiento para procesar.\n";
        return;
    }

    print "\nProcesando solicitudes de reabastecimiento...\n";

    my $actual = $lista_reabastecimientos->{cabeza};

    do {
        
        my $siguiente_nodo = $actual->get_next();
        my $reabastecimiento = $actual->get_data();

        print "\n-----------------------------\n";
        print "Departamento: " . $reabastecimiento->get_departamento_solicitante();
        print "\nMedicamento:  " . $reabastecimiento->get_medicamento_requerido();
        print "\nCantidad:     " . $reabastecimiento->get_cantidad_solicitada();
        print "\nFecha:        " . $reabastecimiento->get_fecha_solicitud();
        print "\n-----------------------------\n";

        print "¿Desea aprobar esta solicitud? (s/n): ";
        my $opcion = <STDIN>;
        chomp $opcion;

        if ($opcion eq "s") {

            my $nombre_buscado = $reabastecimiento->get_medicamento_requerido();
            my $cantidad_pedida = $reabastecimiento->get_cantidad_solicitada();
            
            my $nodo_inv = $lista_inventario->{cabeza};
            my $hallado_en_inv = 0;

            while (defined($nodo_inv)) {
                my $med = $nodo_inv->get_data();

                if (lc($med->get_codigo_medicamento()) eq lc($nombre_buscado)) {
                    $hallado_en_inv = 1;

                    if ($med->get_stock() >= $cantidad_pedida) {
                        
                        my $nuevo_stock = $med->get_stock() - $cantidad_pedida;
                        $med->set_stock($nuevo_stock);
                        $reabastecimiento->set_estado("aprobada");

                        ReporteListaDoblemente->generar_reporte($lista_inventario);
                        
                        print "\n[APROBADA] Stock actualizado. Nuevo stock de " . $med->get_nombre_comercial() . ": $nuevo_stock\n";
                        
                        $lista_reabastecimientos->eliminar($reabastecimiento);
                        ReporteListaCircularDoble->generar_reporte($lista_reabastecimientos); 
                    } else {
                        $reabastecimiento->set_estado("rechazada");
                        ReporteListaCircularDoble->generar_reporte($lista_reabastecimientos);
                        print "\n[RECHAZADA] Stock insuficiente (Disponible: " . $med->get_stock() . ")\n";
                    }
                    last;
                }
                $nodo_inv = $nodo_inv->get_next();
            }

            if (!$hallado_en_inv) {
                print "\n[ERROR] El medicamento '$nombre_buscado' no existe en el inventario.\n";
            }

        } else {
            print "\nSolicitud ignorada/postergada.\n";
        }

        last if $lista_reabastecimientos->is_empty();

        $actual = $siguiente_nodo;

    } while (defined($lista_reabastecimientos->{cabeza}) && $actual != $lista_reabastecimientos->{cabeza});

    print "\nFin del procesamiento de solicitudes.\n";
    ReporteListaCircularDoble->generar_reporte($lista_reabastecimientos);
}

1;