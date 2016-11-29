with Ada.Text_IO, Ada.Float_Text_IO, Ada.Characters.Handling;
use Ada.Text_IO, Ada.Float_Text_IO, Ada.Characters.Handling;

package body Parser_Svg is


    procedure Chargement_Bezier(Nom_Fichier : String; L : out Liste) is

        Nb_Points : Positive := 100;
        File : File_Type;
        Cour : Character := ' ';
        Point_Precedent : Point2D := (0.0, 0.0);
        --P1 : Point2D;


        procedure Relative_To_Absolue(Relative : Boolean; P : in out Point2D) is
        begin
            if Relative then
                P(1) := P(1) + Point_Precedent(1);
                P(2) := P(2) + Point_Precedent(2);
            end if;
        end Relative_To_Absolue;


        procedure Get_Point_Depart(Relative : Boolean) is
            P1 : Point2D;
            EOL : Boolean;
        begin
            Get(File, P1(1)); New_Line; Put(P1(1));
            Get(File, Cour); Put(Cour); -- ','
            Get(File, P1(2)); New_Line; Put(P1(2));
            Relative_To_Absolue(Relative, P1);
            Insertion_Queue(L, P1);
            Put_Line("Point Precedent := P1");
            Point_Precedent := P1;

            Look_Ahead(File, Cour, EOL);
            if Is_Digit(Cour) or Cour = '-' then
                Put_Line("Recursion");
                Get_Point_Depart(Relative);
            end if;
        end Get_Point_Depart;


        procedure Get_Points_Controle(Relative, Quadratique : Boolean) is
          C1, C2, P2 : Point2D;
          Segments_Bezier : Liste;
          EOL : Boolean;
        begin
            Get(File, C1(1)); New_Line; Put(C1(1));
            Get(File, Cour); Put(Cour);-- ','
            Get(File, C1(2)); New_Line; Put(C1(2));
--            Get(File, Cour); -- ' '
            
            Get(File, C2(1)); New_Line; Put(C2(1));
            Get(File, Cour); Put(Cour);-- ','
            Get(File, C2(2)); New_Line; Put(C2(2));
--            Get(File, Cour); -- ' '
            
            --Put_Line("Get C1 et C2");
            Relative_To_Absolue(Relative, C1);
            Relative_To_Absolue(Relative, C2);
            if Quadratique then
                Bezier(Point_Precedent, C1, C2, Nb_Points, Segments_Bezier);
                Point_Precedent := C2;
            else
                Get(File, P2(1)); New_Line; Put(P2(1));
                Get(File, Cour); Put(Cour);
                Get(File, P2(2)); New_Line; Put(P2(2));
                Relative_To_Absolue(Relative, P2);
                Bezier(Point_Precedent, C1, C2, P2, Nb_Points, Segments_Bezier);
                Point_Precedent := P2;
            end if;
            --Put_Line("Apres if quadratique.");

            Fusion(L, Segments_Bezier);
            --Put_Line("Apres Fusion");
            Get(File, Cour); Put(Cour);
            Look_Ahead(File, Cour, EOL);
           -- Put("Is_Digit(Cour) : "); Put(Boolean'Image(Is_Digit(Cour))); New_Line;
            if Is_Digit(Cour) or Cour = '-' then
                Put_Line("Recursion");
                Get_Points_Controle(Relative, Quadratique);
            --else
            --    if Quadratique then
            --        Point_Precedent := C2;
            --        Put_Line("Point Precedent := C2");
            --    else
            --        Point_Precedent := P2;
            --        Put_Line("Point Precedent := P2");
            --    end if;
            end if;
        end Get_Points_Controle;


        procedure Get_Ligne(Relative : Boolean) is
            P2 : Point2D;
        begin
            Put_Line("Ligne");
            Get(File, P2(1));
            Get(File, Cour); Put(Cour);-- ','
            Get(File, P2(2));
            Relative_To_Absolue(Relative, P2);
            Insertion_Queue(L, P2);
            Point_Precedent := P2;
        end Get_Ligne;


        procedure Get_Ligne_Horizontale(Relative : Boolean) is
            P2 : Point2D;
        begin
            Put_Line("Ligne Horizontale");
            Get(File, P2(1));
            P2(2) := Point_Precedent(2);
            Relative_To_Absolue(Relative, P2);
            Insertion_Queue(L, P2);
            Point_Precedent := P2;
        end Get_Ligne_Horizontale;


        procedure Get_Ligne_Verticale(Relative : Boolean) is
            P2 : Point2D;
        begin
            Put_Line("Ligne Verticale");
            P2(1) := Point_Precedent(1);
            Get(File, P2(2));
            Relative_To_Absolue(Relative, P2);
            Insertion_Queue(L, P2);
            Point_Precedent := P2;
        end Get_Ligne_Verticale;


    begin
        Open(File, In_File, Nom_Fichier);

        -- Boucle qui trouve 'd' en début de ligne
        while Cour /= 'd' loop
            Get(File, Cour);
            if Cour = ' ' then
                while Cour = ' ' loop
                    Get(File, Cour);
                end loop;
                if Cour /= 'd' then
                    Skip_Line(File);
                else
                    exit;
                end if;
            elsif Cour /= 'd' then
                Skip_Line(File);
            end if;
        end loop;
    
        Put(Cour);
        Get(File, Cour); -- =
        Put(Cour);
        Get(File, Cour); -- "
        Put(Cour);
        Get(File, Cour); -- m ou M
        Put(Cour);
        Get(File, Cour); -- ' '
        Put(Cour);

        Get_Point_Depart(False);


        while not End_Of_Line(File) loop
            Get(File, Cour);
            New_Line; Put(Cour);
            Put_Line("Case ");
            case Cour is
                when 'c' | 'C' =>
                    Put("c ou C : "); Put(Cour);
                    Get_Points_Controle(Is_Lower(Cour), False);
                    --Get_Points_Controle(False, False);

                when 'q' | 'Q' =>
                    Get_Points_Controle(Is_Lower(Cour), True);

                when 'l' | 'L' =>
                    Get_Ligne(Is_Lower(Cour));

                when 'h' | 'H' =>
                    Get_Ligne_Horizontale(Is_Lower(Cour));

                when 'v' | 'V' =>
                    Get_Ligne_Verticale(Is_Lower(Cour));

                when '"' =>
                    exit;

                when others =>
                    null; --Put(Cour);
            end case;
            Put_Line("End Case ");
        end loop;

        Close(File);
                
    end Chargement_Bezier;

end;
