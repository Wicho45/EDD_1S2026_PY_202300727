package Controlador::VisualizarHistorial;

use strict;
use warnings;

sub visualizar_historial {
    my ($class, $historial_solicitudes) = @_;

    # Verificar si está vacío
    if ($historial_solicitudes->is_empty()) {
        print "\nNo hay solicitudes en el historial.\n";
        return;
    }

    my $actual = $historial_solicitudes->{cabeza};

    print "\n===== HISTORIAL DE SOLICITUDES =====\n";

    do {
        my $solicitud = $actual->get_data();

        print "\n-----------------------------\n";
        print "Departamento       : " . $solicitud->get_departamento_solicitante() . "\n";
        print "Código medicamento : " . $solicitud->get_medicamento_requerido() . "\n";
        print "Cantidad solicitada: " . $solicitud->get_cantidad_solicitada() . "\n";
        print "Prioridad          : " . $solicitud->get_prioridad() . "\n";
        print "Justificación      : " . $solicitud->get_justificacion() . "\n";
        print "Estado             : " . $solicitud->get_estado() . "\n";
        print "Fecha solicitud    : " . $solicitud->get_fecha_solicitud() . "\n";

        $actual = $actual->get_next();

    } while ($actual != $historial_solicitudes->{cabeza});

    print "\n====================================\n";
}

1;