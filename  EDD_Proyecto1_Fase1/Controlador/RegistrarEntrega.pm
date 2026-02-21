package Controlador::RegistrarEntrega;

use strict;
use warnings;

use Modelo::Entrega;
use constant Entrega => 'Modelo::Entrega';

sub registrarEntrega {
    my ($class, $lista_proveedores) = @_;

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

        my $nuevo = Entrega->new($nit_proveedor, $fecha_entrega, $numero_factura, $codigo_medicamento, $cantidad_entregada);

        my $actual = $lista_proveedores->{cabeza};
        while (defined($actual->get_next())){
            if ($actual->get_data()->get_nit() eq $nit_proveedor){
                $actual->get_data()->{historial}->insertar($nuevo);
                print "\nEntrega registrada exitosamente.\n";
                last;
            }
        }

        print "\n¿Desea registrar otro? (s/n): ";
        $continuar = <STDIN>; 
        chomp $continuar;
    }
    return 1;
}

1;