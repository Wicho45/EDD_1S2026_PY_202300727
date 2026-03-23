use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";

use Controlador::ListaSimple;
use constant ListaSimple => 'Controlador::ListaSimple';

use Controlador::ListaCircular;
use constant ListaCircular => 'Controlador::ListaCircular';

use Controlador::ListaDoblemente;
use constant ListaDoblemente => 'Controlador::ListaDoblemente';

use Modelo::Medicamento;
use constant Medicamento => 'Modelo::Medicamento';

use Modelo::Proveedor;
use constant Proveedor => 'Modelo::Proveedor';

use Controlador::RegistraMedicamento;
use constant RegistraMedicamento => 'Controlador::RegistraMedicamento';

use Controlador::RegistrarProveedor;
use constant RegistrarProveedor => 'Controlador::RegistrarProveedor';

use Controlador::RegistrarEntrega;
use constant RegistrarEntrega => 'Controlador::RegistrarEntrega';

use Controlador::ProcesarReabastecimiento;
use constant ProcesarReabastecimiento => 'Controlador::ProcesarReabastecimiento';

use Controlador::ListaCircularDoblemente;
use constant ListaCircularDoblemente => 'Controlador::ListaCircularDoblemente';

use Controlador::MatrizDispersa;
use constant MatrizDispersa => 'Controlador::MatrizDispersa';

use Controlador::ConsultarInventario;
use constant ConsultarInventario => 'Controlador::ConsultarInventario';

use Controlador::ConsultarDisponibilidad;
use constant ConsultarDisponibilidad => 'Controlador::ConsultarDisponibilidad';

use Controlador::SolicitarReabastecimiento;
use constant SolicitarReabastecimiento => 'Controlador::SolicitarReabastecimiento';

use Controlador::VisualizarHistorial;
use constant VisualizarHistorial => 'Controlador::VisualizarHistorial';

sub main {

    my $lista_inventario = ListaDoblemente -> new();
    my $lista_proveedores = ListaCircular -> new();
    my $lista_reabastecimientos = ListaCircularDoblemente -> new();
    my $historial_solicitudes = ListaCircularDoblemente -> new();

    #matriz dispersa 
    my $matriz_inventario = MatrizDispersa -> new(0,0);
    my $mapeo_medicamentos = ListaSimple -> new();
    my $mapeo_laboratorios = ListaSimple -> new();


    while (1){
        print "\n------------- Inicio de sesión -------------\n";
        print "\n1. Administrador";
        print "\n2. Usuario departamental";
        print "\n3. Salir\n";
        print "\nSelecccione una opción: \n";

        my $opcion_inicio = <STDIN>;
        chomp $opcion_inicio;

        my $terminar = inicio_sesion($opcion_inicio, $lista_inventario, $lista_proveedores, $lista_reabastecimientos, $matriz_inventario, $mapeo_medicamentos, $mapeo_laboratorios, $historial_solicitudes);
        last if $terminar;
    }   
}

sub inicio_sesion {
    
    my ($opcion, $lista_inventario, $lista_proveedores, $lista_reabastecimientos, $matriz, $map_med, $map_lab, $historial_solicitudes) = @_;

    if ($opcion == 1){
        print "\n Ingrese usuario: \n";
        my $usuario_admin = <STDIN>;
        chomp $usuario_admin;

        print "\n Ingrese contraseña: \n";
        my $contrasena_admin = <STDIN>;
        chomp $contrasena_admin;
        
        if ($usuario_admin eq "admin" and $contrasena_admin eq "admin" ){
            menu_administrador($lista_inventario, $lista_proveedores, $lista_reabastecimientos, $matriz, $map_med, $map_lab);
        }else{
            print "\n Usuario o contraseña incorrectos. Intente nuevamente.\n";
            return 0;
        }
    } elsif ($opcion == 2){

        #Usuario departamental quemado Nombre: "user" Contraseña: "user"

        print "\n Ingrese usuario: \n";
        my $usuario_departamental = <STDIN>;
        chomp $usuario_departamental;

        print "\n Ingrese contraseña: \n";
        my $contrasena_departamental = <STDIN>;
        chomp $contrasena_departamental;

        if ($usuario_departamental eq "user" and $contrasena_departamental eq "user" ){
            menu_usuario_departamental($lista_inventario, $lista_proveedores, $lista_reabastecimientos, $matriz, $map_med, $map_lab, $historial_solicitudes);
        }else{
            print "\n Usuario o contraseña incorrectos. Intente nuevamente.\n";
            return 0;
        }
    } elsif ($opcion == 3){
        print "\n Saliendo del programa. ¡Hasta luego!\n";
        return 1;
    } else {
        print "\n Opción inválida. Por favor, seleccione una opción válida.\n";
        return 0;
    }

}


sub menu_administrador {
    my ($lista_inventario, $lista_proveedores, $lista_reabastecimientos, $matriz, $map_med, $map_lab) = @_;
    my $continuar_menu = 1;

    while ($continuar_menu) { 
        print "\n------------- Administrador -------------\n";
        print "1. Registrar medicamentos\n";
        print "2. Carga masiva de medicamentos\n";
        print "3. Gestionar proveedores\n";
        print "4. Registrar entrega de proveedor\n";
        print "5. Procesar solicitudes de reabastecimiento\n";
        print "6. Visualizar inventario completo\n";
        print "7. Consultar inventario por proveedor\n";
        print "8. Cerrar Sesión\n";
        print "\nSeleccione una opción: ";

        my $opcion = <STDIN>;
        chomp $opcion;

        if ($opcion == 1) {
            print "\n--- Registrar medicamentos ---\n";
            RegistraMedicamento->registrarMedicamento($lista_inventario, $matriz, $map_med, $map_lab);
            
        } elsif ($opcion == 2) {
            print "\n-------------- Carga Masiva --------------\n";
            print "Ingrese la ruta del archivo a cargar:\n";
            my $ruta_archivo = <STDIN>;
            chomp $ruta_archivo;
            RegistraMedicamento->cargaMasiva($lista_inventario, $matriz, $map_med, $map_lab, $ruta_archivo);

            #Ruta de prueba para cargar masiva: /Volumes/Información y Archivos/Separadores cartapacios/Archivo_calificacion_f1_2.csv

        } elsif($opcion == 3){
            print "\n-------------- Gestionar Proveedores --------------\n";
            RegistrarProveedor->registrarProveedor($lista_proveedores);
        } elsif($opcion == 4){
            print "\n-------------- Registrar Entregas --------------\n";
            RegistrarEntrega->registrarEntrega($lista_proveedores, $lista_inventario);
        
        } elsif ($opcion == 5){
            print "\n-------------- Procesar Solicitudes de Reabastecimiento --------------\n";
            ProcesarReabastecimiento->procesarReabastecimiento($lista_inventario ,$lista_reabastecimientos);

        }elsif($opcion == 6){
            
            print "\n-------------- Visualizar Inventario --------------\n";
            $lista_inventario->imprimir();

        } elsif ($opcion == 7){
            print"\n-------------- Consultar Inventario por Proveedor --------------\n";
            ConsultarInventario->consultar_por_medicina($matriz, $map_med, $map_lab);

        } elsif ($opcion == 8) {
            print "\nCerrando sesión de administrador...\n";
            $continuar_menu = 0; 

        } else {
            print "\nOpción inválida.\n";
        }
    }
    return 0; 
}

sub menu_usuario_departamental {

    my ($lista_inventario, $lista_proveedores, $lista_reabastecimientos, $matriz, $map_med, $map_lab, $historial_solicitudes) = @_;
    my $continuar_menu = 1;

    while ($continuar_menu) {
        print "\n------------- Usuario departamental -------------\n";
        print "1. Consultar disponibilidad de medicamentos\n";
        print "2. Solicitar reabastecimiento\n";
        print "3. Visualizar historial de solicitudes\n";
        print "4. Cerrar Sesión\n";
        print "\nSeleccione una opción: ";

        my $opcion = <STDIN>;
        chomp $opcion;
    

        if ($opcion == 1) {
            print "\n-------------- Consultar Disponibilidad de Medicamentos --------------\n";
            ConsultarDisponibilidad->consultarDisponibilidad($lista_inventario);
        }elsif($opcion == 2){
            print "\n-------------- Solicitar Reabastecimiento --------------\n";
            SolicitarReabastecimiento->solicitar($lista_inventario, $lista_reabastecimientos, $historial_solicitudes);
        }elsif($opcion == 3){
            print "\n-------------- Historial de Solicitudes --------------\n";
            VisualizarHistorial->visualizar_historial($historial_solicitudes);

        }elsif($opcion == 4){
            print "\nCerrando sesión de usuario departamental...\n";
            $continuar_menu = 0;

        }else{
            print "\nOpción inválida.\n";
        }
    }
    return 0;
}

main() unless caller;

