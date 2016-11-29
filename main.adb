with Ada.Command_Line; use Ada.Command_Line;
with STL; use STL;
with Parser_Svg; use Parser_Svg;
with Ada.Text_IO; use Ada.Text_IO;
with Math; use Math;

procedure Main is
    Segments : Liste_Points.Liste;
    Facettes : Liste_Facettes.Liste;
begin

    if Argument_Count /= 2 then
        Put_Line(Standard_Error,
        "usage : " & Command_Name &
        " fichier_entree.svg fichier_sortie.stl");
        Set_Exit_Status(Failure);
        return;
    end if;

    --on charge la courbe de bezier et la convertit en segments
    Chargement_Bezier(Argument(1), Segments);
    --on convertit en facettes par rotation
    Creation(Segments, Facettes);
    --on sauvegarde le modele obtenu
    Sauvegarder(Argument(2), Facettes);
end;
