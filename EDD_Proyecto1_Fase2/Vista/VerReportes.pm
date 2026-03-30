package Vista::VerReportes;

use strict;
use warnings;
use Gtk3;
use utf8;

use Reportes::ReporteAvl;
use Reportes::ReporteBst;
use Reportes::ReporteBtree;
use Reportes::ReporteMatriz;
use Reportes::ReporteListaDoblemente;
use Reportes::ReporteListaCircularDoble;

sub mostrar_ventana {
    my ($class, $avl, $bst, $btree, $matriz, $l_doble, $l_circular) = @_;

    my $window = Gtk3::Window->new('toplevel');
    $window->set_title("Visor de Reportes - Medtrack");
    $window->set_default_size(900, 700);
    $window->set_position('center');

    my $vbox_main = Gtk3::Box->new('vertical', 10);
    $vbox_main->set_border_width(10);
    $window->add($vbox_main);

    my $scroll = Gtk3::ScrolledWindow->new(undef, undef);
    $scroll->set_policy('automatic', 'automatic');
    $vbox_main->pack_start($scroll, 1, 1, 0);

    my $vbox_content = Gtk3::Box->new('vertical', 20);
    $vbox_content->set_border_width(10);
    $scroll->add_with_viewport($vbox_content);

    my @config = (
        { nombre => "Árbol AVL - Personal Médico", obj => $avl, gen => "Reportes::ReporteAvl", img => "Imagenes/reporte_personal_avl.png" },
        { nombre => "Árbol BST - Equipos Médicos", obj => $bst, gen => "Reportes::ReporteBst", img => "Imagenes/reporte_equipo_bst.png" },
        { nombre => "Árbol B - Suministros", obj => $btree, gen => "Reportes::ReporteBtree", img => "Imagenes/reporte_suministros_btree.png" },
        { nombre => "Matriz Dispersa - Proveedores vs Fabricantes", obj => $matriz, gen => "Reportes::ReporteMatriz", img => "Imagenes/matriz_proveedores.png" },
        { nombre => "Lista Doblemente Enlazada - Medicamentos", obj => $l_doble, obj_is_list => 1, gen => "Reportes::ReporteListaDoblemente", img => "Imagenes/reporte_inventario.png" },
        { nombre => "Lista Circular Doble - Proveedores", obj => $l_circular, obj_is_list => 1, gen => "Reportes::ReporteListaCircularDoble", img => "Imagenes/reporte_proveedores.png" }
    );

    foreach my $item (@config) {
        my $vbox_item = Gtk3::Box->new('vertical', 5);
        
        my $lbl_titulo = Gtk3::Label->new();
        $lbl_titulo->set_markup("<b>$item->{nombre}</b>");
        $lbl_titulo->set_halign('start');
        $vbox_item->pack_start($lbl_titulo, 0, 0, 0);

        my $vacio = 0;
        if (defined $item->{obj}) {
            if ($item->{obj_is_list}) { $vacio = $item->{obj}->is_empty(); }
            else { $vacio = ($item->{gen} eq "Reportes::ReporteMatriz") ? ($item->{obj}->{total_datos} == 0) : $item->{obj}->is_empty(); }
        } else { $vacio = 1; }

        if (!$vacio) {
            eval { $item->{gen}->generar_reporte($item->{obj}); };
            if (-e $item->{img}) {
                my $image = Gtk3::Image->new_from_file($item->{img});
                $vbox_item->pack_start($image, 0, 0, 5);
            } else {
                $vbox_item->pack_start(Gtk3::Label->new("Error al generar la imagen."), 0, 0, 5);
            }
        } else {
            my $lbl_vacio = Gtk3::Label->new("Estructura vacía - No hay datos para mostrar.");
            $lbl_vacio->set_halign('start');
            $vbox_item->pack_start($lbl_vacio, 0, 0, 5);
        }

        my $separator = Gtk3::Separator->new('horizontal');
        $vbox_item->pack_start($separator, 0, 0, 10);
        $vbox_content->pack_start($vbox_item, 0, 0, 0);
    }

    my $btn_regresar = Gtk3::Button->new_with_label("Regresar a Admin");
    $btn_regresar->set_size_request(150, 40);
    $btn_regresar->signal_connect(clicked => sub { $window->destroy(); });
    $vbox_main->pack_start($btn_regresar, 0, 0, 5);

    $window->show_all();
}

1;