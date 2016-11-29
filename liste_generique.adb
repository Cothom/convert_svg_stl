with Ada.Unchecked_Deallocation;
with Ada.Text_Io;
use Ada.Text_Io;

package body Liste_Generique is

    procedure Liberer is new Ada.Unchecked_Deallocation(Cellule, Pointeur);

    procedure Vider(L : in out Liste) is
        Cour, Prec : Pointeur;
    begin
        Cour := L.Debut;
        while Cour /= null loop
            Prec := Cour;
            Cour := Cour.Suivant;
            Liberer(Prec);
        end loop;
        L.Debut := null;
        L.Fin := null;
        L.Taille := 0;
    end;

    procedure Insertion_Tete(L : in out Liste ; E : Element) is
    begin
        L.Debut := new Cellule'(E, L.Debut);
        L.Taille := L.Taille + 1;
    end;

    procedure Insertion_Queue(L : in out Liste ; E : Element) is
    begin
        if L.Debut = null then
            L.Debut := new Cellule'(E, null);
            L.Fin := L.Debut;
        else
            L.Fin.Suivant := new Cellule'(E, null);
            L.Fin := L.Fin.Suivant;
        end if;
        L.Taille := L.Taille + 1;
    end;

    procedure Parcourir (L : Liste) is
        Cour : Pointeur;
    begin
        Cour := L.Debut;
        while Cour /= null loop
            Traiter(Cour.Contenu);
            Cour := Cour.Suivant;
        end loop;
    end;

    procedure Parcourir_Par_Couples(L : Liste) is
        Cour : Pointeur;
    begin
        if L.Debut /= null then
            Cour := L.Debut;
            while Cour.Suivant /= null loop
                Traiter(Cour.Contenu, Cour.Suivant.Contenu);
                Cour := Cour.Suivant;
            end loop;
        end if;
    end;

    procedure Fusion(L1 : in out Liste ; L2 : in out Liste) is
    begin
        L1.Fin.Suivant := L2.Debut;
        L1.Taille := L1.Taille + L2.Taille;
        L1.Fin := L2.Fin;
        L2.Debut := null;
        L2.Fin := null;
        L2.Taille := 0;
    end;

    function Taille(L : Liste) return Natural is
    begin
        return L.Taille;
    end;

    function Tete(L : Liste) return Element is
    begin
        return L.Debut.Contenu;
    end;

    function Queue(L : Liste) return Element is
    begin
        return L.Fin.Contenu;
    end;

end;
