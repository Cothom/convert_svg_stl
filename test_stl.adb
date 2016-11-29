with STL; use STL;
with Parser_Svg; use Parser_Svg;
with Ada.Text_IO; use Ada.Text_IO;
with Math; use Math;

procedure Test_STL is
   Segments : Liste_Points.Liste;
   Facettes : Liste_Facettes.Liste;
begin

    Creation(Segments, Facettes);
    Sauvegarder("test1.stl", Facettes);

end;
