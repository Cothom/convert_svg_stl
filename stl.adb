with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Float_Text_IO;
use Ada.Float_Text_IO;
with Ada.Numerics;
use Ada.Numerics;
with Ada.Numerics.Elementary_Functions;
use Ada.Numerics.Elementary_Functions;

package body STL is

    procedure Creation(Segments : in out Liste_Points.Liste ;
        Facettes :    out Liste_Facettes.Liste) is


        Xmin, Ymin : Float;
        Nb_Rotations : Positive := 360;
        file2 : File_Type;

        procedure NewXMin(Point : in out Point2D) is
            -- Procédure permettant d'actualiser Xmin au fur et à mesure de la recherche du minimum
        begin
            if Point(1) < Xmin then
                Xmin := Point(1);
            end if;
        end NewXMin;


        procedure NewYMin(Point : in out Point2D) is
            -- De même que NewYMin pour la coordonnée Y
        begin
            if Point(2) < Ymin then
                Ymin := Point(2);
            end if;
        end NewYMin;


        procedure TranslatePoint(Point : in out Point2D) is
            -- Procédure générique de Traiter pour la procédure TranslateImage générique de Liste_Points.Parcourir
        begin
            Point(1) := Point(1) - Xmin;
            Point(2) := Point(2) - Ymin;
        end TranslatePoint;


        function Rotation(P : Point3D) return Point3D is
            -- Rotation autour de l'axe y = 0
            -- La coordonnée en x est invariante
            Pas : Float := 360.0/Float(Nb_Rotations);
        begin
            return (P(1), P(2)*Cos(Pas) - P(3)*Sin(Pas), P(2)*Sin(Pas) + P(3)*Cos(Pas)); 
        end Rotation;


        procedure RangeeFacettes(P1, P2 : Point2D) is
            -- Procédure créant la rangée de facette entre les deux disques formés par les points voisins
            -- Procédure générique de Traiter pour la procédure ParcourirSegments générique de Liste_Points.Parcourir_Par_Couples

            Cour1, Cour2 : Point3D;
        begin
            Cour1 := (P1(1), P1(2), 0.0);
            Cour2 := (P2(1), P2(2), 0.0);
            for I in 1 .. Nb_Rotations loop
                Liste_Facettes.Insertion_Queue(Facettes, (Cour1, Rotation(Cour1), Cour2));
                Liste_Facettes.Insertion_Queue(Facettes, (Cour2, Rotation(Cour1), Rotation(Cour2)));
                Cour1 := Rotation(Cour1);
                Cour2 := Rotation(Cour2);
            end loop;
        end RangeeFacettes;


        function Exist(Nom_Fichier : String) return Boolean is
        -- Fonction testant l'existence d'un fichier

            fichier_exist : File_Type;
        begin
            Open(fichier_exist, Out_File, Nom_Fichier);
            Close(fichier_exist);
            return True;

        exception
            when Name_Error => return False;
            when others => raise;

        end Exist;

        procedure Affiche_Point(P : in out Point2D) is
        begin
            Put(file2, Float'Image(P(1))); Put(file2, ",");
            Put(file2, Float'Image(P(2))); Put(file2, " ");
        end Affiche_Point;

        procedure XMinimum is new Liste_Points.Parcourir(NewXMin); -- Trouve la coordonnée minimale en X
        procedure YMinimum is new Liste_Points.Parcourir(NewYMin); -- Trouve la coordonnée minimale en Y
        procedure TranslateImage is new Liste_Points.Parcourir(TranslatePoint); -- Translate tous les points de (-Xmin, -Ymin)
        procedure ParcourirSegments is new Liste_Points.Parcourir_Par_Couples(RangeeFacettes); -- Parcours les points voisins afin de former toutes les rangées de facettes
        procedure Affiche is new Liste_Points.Parcourir(Affiche_Point);



    -- -- PARTIE PRINCIPALE DE LA PROCEDURE CREATION -- --


    begin
        -- On commence par trouver Xmin et Ymin

        --Affiche(Segments);

        if Exist("segments.svg") then
            Open(file2, Out_File, "segments.svg");
        else
            Create(file2, Out_File, "segments.svg");
        end if;

        Put_Line(file2, "<svg height=""1052"" width=""744"">");
        Put(file2, "<polygon points=""");
        Affiche(Segments);
       Put(file2, """ style=""fill:none;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"" />");
        New_Line(file2);
        Put_Line(file2, "</svg>");
        Close(file2);

        Xmin := Liste_Points.Tete(Segments)(1);
        Xminimum(Segments);
        Ymin := Liste_Points.Tete(Segments)(2);
        Yminimum(Segments);

        -- On translate la figure de (-Xmin, -Ymin)

        TranslateImage(Segments);

        -- On rajoute les points en tête et en queue si nécessaire afin qu'il n'y ait pas de trous

        if Liste_Points.Tete(Segments)(2) > 0.0 then
            Liste_Points.Insertion_Tete(Segments, (Liste_Points.Tete(Segments)(1), 0.0));
        end if;
        if Liste_Points.Queue(Segments)(2) > 0.0 then
            Liste_Points.Insertion_Queue(Segments, (Liste_Points.Queue(Segments)(1), 0.0));
        end if;

        -- Il suffit ensuite d'appeler ParcourirSegments pour former toutes les facettes
        ParcourirSegments(Segments);
    end;


    procedure Sauvegarder(Nom_Fichier : String ;
        Facettes : Liste_Facettes.Liste) is


        file : File_Type;


        procedure EnTeteSTL is
        -- Formation de l'en-tête du fichier STL
        begin
            Put_Line(file, "solid Name");
        end EnTeteStL;


        procedure PiedSTL is 
        -- Formation du pied du fichier STL
        begin
            Put_Line(file, "endsolid Name");
        end PiedSTL;


        procedure FacetteSTL(F : in out Facette) is
        -- Formation d'un seule facette dans le fichier STL
        begin
            Put_Line(file, "    facet");
            Put_Line(file, "        outer loop");
            Put(file, "            vertex "); Put(file, F.P1(1)); Put(file, " "); Put(file, F.P1(2)); Put(file, " "); Put(file, F.P1(3)); New_Line(file);
            Put(file, "            vertex "); Put(file, F.P2(1)); Put(file, " "); Put(file, F.P2(2)); Put(file, " "); Put(file, F.P2(3)); New_Line(file);
            Put(file, "            vertex "); Put(file, F.P3(1)); Put(file, " "); Put(file, F.P3(2)); Put(file, " "); Put(file, F.P3(3)); New_Line(file);
            Put_Line(file, "        endloop");
            Put_Line(file, "    endfacet");
        end FacetteSTL;


        function Exist(Nom_Fichier : String) return Boolean is
        -- Fonction testant l'existence d'un fichier

            fichier_exist : File_Type;
        begin
            Open(fichier_exist, Out_File, Nom_Fichier);
            Close(fichier_exist);
            return True;

        exception
            when Name_Error => return False;
            when others => raise;

        end Exist;

        procedure BodySTL is new Liste_Facettes.Parcourir(FacetteSTL); -- Formation de toutes les facettes dans le fichier STL



    -- -- PARTIE PRINCIPALE DE LA PROCEDURE SAUVEGARDER -- --


    begin
        -- Il suffit d'ouvrir le fichier en mode Ecriture et d'appeler successivement les procédures d'écriture
        -- puis de fermer le fichier

        if Exist(Nom_Fichier) then
            Open(file, Out_File, Nom_Fichier);
        else
            Create(file, Out_File, Nom_Fichier);
        end if;
        
        EnTeteSTL;
        BodySTL(Facettes);
        PiedSTL;
        Close(file);
    end;

end;
