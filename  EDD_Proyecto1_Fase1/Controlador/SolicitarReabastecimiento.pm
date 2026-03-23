package Controlador::SolicitarReabastecimiento;

use strict;
use warnings;

use Modelo::Reabastecimiento;
use constant Reabastecimiento => 'Modelo::Reabastecimiento';

use Reportes::ReporteListaCircularDoble;
use constant ReporteListaCircularDoble => 'Reportes::ReporteListaCircularDoble';

sub solicitar {
    my ($class, $lista_inventario, $lista_reabastecimientos, $historial_solicitudes) = @_;
    my $continuar = "s";

    if ($lista_inventario->is_empty()) {
        print "\n[!] No hay medicamentos registrados.\n";
        return;
    }

    while (lc($continuar) eq "s") {

        print "\n--- Nueva Solicitud de Reabastecimiento ---\n";

        print "Código del medicamento: ";
        my $codigo = <STDIN>;
        chomp $codigo;

        # Verificar existencia
        my $actual = $lista_inventario->{cabeza};
        my $existe = 0;

        while (defined $actual) {
            my $med = $actual->get_data();
            if (lc($med->get_codigo_medicamento()) eq lc($codigo)) {
                $existe = 1;
                last;
            }
            $actual = $actual->get_next();
        }

        unless ($existe) {
            print "\n[!] El medicamento no existe en el inventario.\n";
            next;
        }

        #Departamento solicitante quemado para el unico usuario
        my $departamento = "Medico | Enfermeros | Personal departamento";

        print "Cantidad requerida: ";
        my $cantidad = <STDIN>;
        chomp $cantidad;

        unless ($cantidad =~ /^\d+$/ && $cantidad > 0) {
            print "\n[!] La cantidad debe ser un número positivo.\n";
            next;
        }

        print "Fecha de solicitud (YYYY-MM-DD): ";
        my $fecha = <STDIN>;
        chomp $fecha;

        print "Prioridad (urgente/alta/media/baja): ";
        my $prioridad = <STDIN>;
        chomp $prioridad;
        $prioridad = lc($prioridad);

        unless ($prioridad =~ /^(urgente|alta|media|baja)$/) {
            print "\n[!] Prioridad inválida.\n";
            next;
        }

        print "Justificación: ";
        my $justificacion = <STDIN>;
        chomp $justificacion;

        my $nueva_solicitud = Reabastecimiento->new(
            $departamento,
            $codigo,
            $cantidad,
            $fecha,
            $prioridad,
            $justificacion
        );

        $lista_reabastecimientos->insertar($nueva_solicitud);
        $historial_solicitudes->insertar($nueva_solicitud);
        ReporteListaCircularDoble->generar_reporte($lista_reabastecimientos);

        print "\nSolicitud registrada correctamente.";
        print "\nEstado: Pendiente de aprobación del administrador.\n";

        print "\n¿Desea realizar otra solicitud? (s/n): ";
        $continuar = <STDIN>;
        chomp $continuar;
    }
    return 1;
}

1;